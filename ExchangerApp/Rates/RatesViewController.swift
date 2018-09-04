import ReRxSwift
import Result
import ReSwift
import RxCocoa
import RxDataSources
import RxKeyboard
import RxSwift
import UIKit

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

extension RatesViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return cellHeight
    }

    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return cellHeight
    }
}

class RatesViewController: UIViewController {
    private let cellHeight: CGFloat = 56

    lazy var mapStateToProps = { (state: MainState) -> RatesViewController.Props in
        var props = RatesViewController.Props(section: [.initial], error: nil)
        state.tableState.data.get(
            ifSuccess: { props.section = [RatesSection(rates: $0)] },
            ifFailure: { props.error = $0 }
        )
        return props
    }

    lazy var mapDispatchToActions = { [intervalRunner] (dispatcher: @escaping DispatchFunction) in
        RatesViewController.Actions(
            select: { rate in
                intervalRunner.stop()
                dispatcher(RatesActions.select(rate).action())
                self.intervalRunner.set(action: .fetch(currency: rate.title, count: rate.value))
                intervalRunner.start()
            },
            changeValue: { rate, value in
                intervalRunner.stop()
                dispatcher(RatesActions.select(rate).action())
                self.intervalRunner.set(action: .fetch(currency: rate.title, count: value))
                intervalRunner.start()
            }
        )
    }

    lazy var connection = Connection(
        store: mainStore,
        mapStateToProps: mapStateToProps,
        mapDispatchToActions: mapDispatchToActions
    )

    private let disposeBag = DisposeBag()
    private let keyboardObservable = RxKeyboard.instance
    private lazy var intervalRunner = IntervalRunner(disposeBag: disposeBag)

    private lazy var controlProperty: (Rate, Observable<String?>) -> Void = { [ratesView, disposeBag] rate, property in
        property
            .map { $0 ?? "" }
            .debounce(1.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .bind(
                onNext: {
                    ratesView.scrollToTop()
                    self.actions.changeValue(rate, $0)
                }
            )
            .disposed(by: disposeBag)
    }

    private lazy var errorBinder = Binder<RatesError?>(self) { (target, error: RatesError?) in
        error.map { error in
            target.ratesView.showError(message: error.errorDescription)
            target.intervalRunner.stop()
        }
    }

    private func configure(_ cell: RatesCell, with rate: Rate) {
        cell.configure(with: rate)
        cell.amountField.rx
            .controlEvent(.editingDidBegin)
            .bind { [actions] in
                actions.select(rate)
            }.disposed(by: disposeBag)
        cell.amountField.rx
            .controlEvent(.editingChanged)
            .flatMap { cell.amountField.rx.text }
            .bind(to: { controlProperty(rate, $0) })
    }

    private lazy var dataSource = RxTableViewSectionedAnimatedDataSource<RatesSection>(
        animationConfiguration: AnimationConfiguration(insertAnimation: .none, reloadAnimation: .none, deleteAnimation: .automatic),
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
        let view = RatesView()
        self.view = view
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
        ).bind { [ratesView] indexPath, rate in
            ratesView.scrollToTop()
            self.actions.select(rate)
            (ratesView.tableView.cellForRow(at: indexPath) as? RatesCell).map { _ = $0.amountField.becomeFirstResponder() }
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
}
