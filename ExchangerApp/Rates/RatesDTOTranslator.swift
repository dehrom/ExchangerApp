import RxSwift

class RatesDTOTranslator: TranslatorProtocol {
    func translate(from data: Data) -> Single<RatesDTO> {
        return Observable<RatesDTO>.create { observable in
            do {
                try observable.onNext(JSONDecoder().decode(RatesDTO.self, from: data))
                observable.onCompleted()
            } catch {
                observable.onError(TranslatorError.underlyingError(error))
            }
            return Disposables.create()
        }.asSingle()
    }
}
