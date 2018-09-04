import ReSwift

struct MainState: StateType, Encodable {
    let tableState: RatesState

    static let initial = MainState(tableState: .initial)
}
