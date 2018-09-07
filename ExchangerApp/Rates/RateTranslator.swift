import Foundation
import RxSwift
import UIKit

class RateTranslator: TranslatorProtocol {
    private lazy var countries: [String: String] = {
        guard let dictionary = Bundle.main.dictionary(for: "Countries") as? [String: String] else { return [:] }
        return dictionary
    }()

    func translate(from: RatesDTO) -> Single<[Rate]> {
        let block: (String, Double) -> Rate = { currency, rate in
            .init(
                image: self.image(for: currency),
                title: currency,
                subTitle: self.countries[currency] ?? "undefined",
                rate: rate,
                value: nil
            )
        }
        var models = from.rates.map { block($0.key, $0.value) }
        models.insert(block(from.baseCurrencyName, 0), at: 0)

        return Observable<[Rate]>.just(models).asSingle()
    }

    private func image(for name: String) -> UIImage {
        return UIImage(named: name.uppercased()) ?? UIImage(named: "default")!
    }
}
