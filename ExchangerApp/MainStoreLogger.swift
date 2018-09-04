import ReSwift

class MainStoreLogger: StoreSubscriber {
    private lazy var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()

    func newState(state: MainState) {
        do {
            let description = try encoder.encode(state)
            print("State: ", String(data: description, encoding: .utf8) ?? "undefined")
        } catch {
            print(error)
        }
    }
}
