import RxSwift

enum TranslatorError: LocalizedError {
    case translationError(String)
    case underlyingError(Error)

    var errorDescription: String? {
        switch self {
        case let .translationError(message):
            return message
        case let .underlyingError(error):
            return error.localizedDescription
        }
    }
}

protocol TranslatorProtocol: class {
    associatedtype SourceType
    associatedtype ResultType

    func translate(from: SourceType) -> Single<ResultType>
}
