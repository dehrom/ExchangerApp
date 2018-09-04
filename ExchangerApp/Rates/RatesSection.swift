import Foundation
import RxDataSources
import UIKit

struct RatesSection: Encodable, Equatable {
    var rates: [Rate]

    static let initial = RatesSection(rates: [])
}

extension RatesSection: AnimatableSectionModelType, IdentifiableType {
    var items: [Rate] {
        return rates
    }

    init(original _: RatesSection, items: [Rate]) {
        rates = items
    }

    var identity: String {
        return "" // We don't have table sections in this app, so we may skip this.
    }
}

struct Rate: Encodable, Equatable, IdentifiableType {
    let image: UIImage
    let title: String
    let subTitle: String
    let rate: Double
    var value: String?

    var identity: String {
        return title
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(image.debugDescription)
        try container.encode(title)
        try container.encode(subTitle)
        try container.encode(rate)
    }
}
