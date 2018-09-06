import ReSwift
import RxCocoa
import RxSwift

class IntervalRunner {
    private let isRunning = PublishRelay<Bool>()
    private let action = PublishRelay<RatesActions?>()
    private let timeInterval = PublishRelay<RxTimeInterval>()
    private let disposeBag: DisposeBag

    init(disposeBag: DisposeBag) {
        self.disposeBag = disposeBag
        schedule()
    }

    func set(action: RatesActions) {
        self.action.accept(action)
    }

    func set(timeInterval: RxTimeInterval) {
        self.timeInterval.accept(timeInterval)
    }

    func start() {
        isRunning.accept(true)
    }

    func stop() {
        isRunning.accept(false)
    }

    private func schedule() {
        Observable.combineLatest(isRunning, action, timeInterval).flatMapLatest {
            (arg: (Bool, RatesActions?, RxTimeInterval)) -> Observable<RatesActions> in
            guard arg.0, let action = arg.1 else { return .empty() }
            return Observable<Int>.interval(arg.2, scheduler: ConcurrentMainScheduler.instance).flatMap { _ in Observable<RatesActions>.just(action) }
        }.bind(onNext: { mainStore.dispatch(action: $0.action()) }).disposed(by: disposeBag)
    }
}
