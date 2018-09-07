import ReRxSwift
import Result
import ReSwift
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

extension RatesViewController {
    struct Configuration {
        let cellHeight: CGFloat = 56
    }
}

extension RatesViewController: Connectable {
    struct Props {
        var section: [RatesSection]
        var error: RatesError?
    }

    struct Actions {
        let select: (Rate) -> Void
        let changeValue: (Rate, String) -> Void
    }
}

// Avoid some animation glitches
extension RatesViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return configuration.cellHeight
    }

    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return configuration.cellHeight
    }
}

class RatesViewController: UIViewController {
    private let configuration: Configuration

    lazy var mapStateToProps = { (state: MainState) -> RatesViewController.Props in
        var props = RatesViewController.Props(section: [.initial], error: nil)
        state.tableState.data.get(
            ifSuccess: { props.section = [RatesSection(rates: $0)] },
            ifFailure: { props.error = $0 }
        )
        return props
    }

    lazy var mapDispatchToActions = { [intervalRunner, ratesView] (_: @escaping DispatchFunction) in
        RatesViewController.Actions(
            select: { rate in
                mainStore.dispatch(action: RatesActions.select(rate).action())
                self.intervalRunner.set(action: .fetch(currency: rate.title, count: rate.value))
            },
            changeValue: { rate, value in
                mainStore.dispatch(action: RatesActions.fetch(currency: rate.title, count: value).action())
                self.intervalRunner.set(action: .fetch(currency: rate.title, count: value))
            }
        )
    }

    lazy var connection = Connection(
        store: mainStore,
        mapStateToProps: mapStateToProps,
        mapDispatchToActions: mapDispatchToActions
    )

    private let disposeBag = DisposeBag()
    private lazy var intervalRunner = IntervalRunner(disposeBag: disposeBag)

    private lazy var controlProperty: (Rate, Observable<String?>) -> Void = { [ratesView, disposeBag] rate, property in
        property
            .debounce(0.5, scheduler: ConcurrentMainScheduler.instance)
            .map { $0 ?? "" }
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .bind(onNext: { self.actions.changeValue(rate, $0) })
            .disposed(by: disposeBag)
    }

    private lazy var errorBinder = Binder<RatesError?>(self) { (target, error: RatesError?) in
        error.map { error in
            target.ratesView.showError(message: error.errorDescription)
            target.intervalRunner.stop()
        }
    }

    private lazy var dataSource = RxTableViewSectionedAnimatedDataSource<RatesSection>(
        animationConfiguration: AnimationConfiguration(
            insertAnimation: .none,
            reloadAnimation: .none,
            deleteAnimation: .automatic
        ),
        configureCell: { [disposeBag, actions] (_, view, indexPath, rate) -> UITableViewCell in
            let cellReuseIdentifier = String(describing: RatesCell.self)
            view.register(RatesCell.self, forCellReuseIdentifier: cellReuseIdentifier)
            return (view.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? RatesCell).map { cell in
                self.configure(cell, with: rate)
                return cell
            } ?? UITableViewCell()
        }
    )

    private var ratesView: RatesView {
        return view as! RatesView
    }

    override func loadView() {
        view = RatesView()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        configuration = .init()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Rates"

        ratesView.tableView.rx.setDelegate(self).disposed(by: disposeBag)
        connection.bind(\Props.section, to: ratesView.tableView.rx.items(dataSource: dataSource))
        connection.bind(\Props.error, to: errorBinder)

        Observable.zip(
            ratesView.tableView.rx.itemSelected,
            ratesView.tableView.rx.modelSelected(Rate.self)
        ).bind { [ratesView, actions] indexPath, rate in
            ratesView.scrollToTop()
            actions.select(rate)
            (ratesView.tableView.cellForRow(at: indexPath) as? RatesCell).map { cell in
                cell.amountField.isUserInteractionEnabled = true
                cell.amountField.becomeFirstResponder()
                cell.amountField.toggleColors()
            }
        }.disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        connection.connect()

        intervalRunner.set(action: .fetch(currency: nil, count: nil))
        intervalRunner.set(timeInterval: 1)
        intervalRunner.start()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        intervalRunner.stop()
        connection.disconnect()
    }

    private func configure(_ cell: RatesCell, with rate: Rate) {
        cell.configure(with: rate)

        cell.amountField.rx
            .controlEvent(.editingDidEnd)
            .bind { cell.amountField.toggleColors() }
            .disposed(by: disposeBag)

        cell.amountField.rx
            .controlEvent(.editingChanged)
            .flatMap { cell.amountField.rx.text }
            .bind(to: { controlProperty(rate, $0) })
    }
}
