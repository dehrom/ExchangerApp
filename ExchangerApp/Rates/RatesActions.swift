import Result
import ReSwift
import RxSwift

enum RatesActions {
    case fetch(currency: String?, count: String?)
    case select(Rate)

    private static let disposeBag = DisposeBag()

    func action() -> Action {
        switch self {
        case let .fetch(currency, value):
            let value = value.flatMap { Double($0) } ?? 0.0
            return FetchAction(
                disposeBag: RatesActions.disposeBag,
                currency: currency,
                value: value
            )
        case let .select(rate):
            return SelectRateAction(selectedRate: rate)
        }
    }
}

extension RatesActions {
    class FetchAction: Action {
        private let service: RatesService
        private let translator: RateTranslator
        private let disposeBag: DisposeBag
        private let currency: String?
        private let value: Double

        init(
            service: RatesService = .init(),
            translator: RateTranslator = .init(),
            disposeBag: DisposeBag,
            currency: String?,
            value: Double
        ) {
            self.service = service
            self.translator = translator
            self.disposeBag = disposeBag
            self.currency = currency
            self.value = value
            fetch()
        }

        private func fetch() {
            service.fetch(for: currency)
                .distinctUntilChanged()
                .flatMap(translator.translate(from:))
                .subscribeOn(MainScheduler.instance)
                .subscribe(
                    onNext: { [value] in mainStore.dispatch(UpdateTableAction(rates: $0, value: value)) },
                    onError: { mainStore.dispatch(PresentableAction(viewState: .failure(.underlyingError($0)))) }
                ).disposed(by: disposeBag)
        }
    }

    private class SelectRateAction: Action {
        let selectedRate: Rate

        init(selectedRate: Rate) {
            self.selectedRate = selectedRate
            rearrange()
        }

        func rearrange() {
            var rates = mainStore.state.tableState.data.value ?? []
            guard
                let index = rates.firstIndex(where: { $0.title == selectedRate.title }),
                index != 0
            else { return }
            rates.remove(at: index)
            rates.insert(selectedRate, at: 0)
            mainStore.dispatch(PresentableAction(viewState: .success(rates)))
        }
    }

    private class UpdateTableAction: Action {
        private let newRates: [Rate]
        private let value: Double

        private var block: (Double) -> String? = { value in
            guard value != 0 else { return nil }
            return .init(format: "%.2f", value)
        }

        init(rates: [Rate], value: Double) {
            newRates = rates
            self.value = value
            calculate()
        }

        func calculate() {
            let existedRates = mainStore.state.tableState.data.value ?? []
            guard
                !existedRates.isEmpty
            else {
                mainStore.dispatch(PresentableAction(viewState: .success(newRates)))
                return
            }
            var tableRates = zip(newRates, existedRates).map { (arg: (newRate: Rate, exRate: Rate)) -> Rate in
                var rate = arg.exRate
                rate.value = block(arg.newRate.rate * self.value)
                return rate
            }
            tableRates[0].value = block(value)
            mainStore.dispatch(PresentableAction(viewState: .success(tableRates)))
        }
    }

    struct PresentableAction: Action {
        let viewState: Result<[Rate], RatesError>
    }
}
