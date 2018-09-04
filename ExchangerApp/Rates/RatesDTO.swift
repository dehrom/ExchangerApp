import Foundation

struct RatesDTO: Codable, Equatable {
    let baseCurrencyName: String
    let date: String
    let rates: [String: Double]

    enum CodingKeys: String, CodingKey {
        case baseCurrencyName = "base"
        case date
        case rates
    }
}
