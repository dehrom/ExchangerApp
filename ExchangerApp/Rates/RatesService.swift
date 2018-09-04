import RxSwift

class RatesService {
    let session: URLSession
    let baseURL = URL(string: "https://revolut.duckdns.org/latest")!
    let translator: RatesDTOTranslator

    init(
        session: URLSession = .init(configuration: .ephemeral),
        translator: RatesDTOTranslator = .init()
    ) {
        self.session = session
        self.translator = translator
    }

    func fetch(for currency: String? = "") -> Observable<RatesDTO> {
        var urlWithParameters = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        urlWithParameters.queryItems = [URLQueryItem(name: "base", value: currency)]
        return session.rx
            .data(request: .init(url: urlWithParameters.url!))
            .flatMap(translator.translate(from:))
    }
}
