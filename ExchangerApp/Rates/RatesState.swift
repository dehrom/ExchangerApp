import Foundation
import Result
import ReSwift

enum RatesError: LocalizedError, Equatable {
    case message(String)
    case underlyingError(Swift.Error)

    var errorDescription: String? {
        switch self {
        case let .message(message):
            return message
        case let .underlyingError(error):
            return error.localizedDescription
        }
    }

    static func == (lhs: RatesError, rhs: RatesError) -> Bool {
        return lhs.errorDescription == rhs.localizedDescription
    }
}

typealias RatesDataType = Result<[Rate], RatesError>

struct RatesState: StateType, Encodable {
    var data: RatesDataType = .success([])

    static let initial = RatesState()

    private enum CodingKeys: String, CodingKey {
        case data
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try data.get(
            ifSuccess: { try container.encode($0, forKey: .data) },
            ifFailure: { try container.encode($0.localizedDescription, forKey: .data) }
        )
    }
}
