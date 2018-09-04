import Foundation
import Result
import ReSwift

func ratesTableReducer(action: Action, state: RatesState?) -> RatesState {
    guard
        var state = state
    else { return .initial }

    switch action {
    case is RatesActions.FetchAction:
        print("loading")
    case let action as RatesActions.PresentableAction:
        state.data = action.viewState
        break
    default:
        break
    }

    return state
}
