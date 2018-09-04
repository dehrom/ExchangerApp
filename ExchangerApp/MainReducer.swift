import ReSwift

func mainReducer(action: Action, state: MainState?) -> MainState {
    return MainState(
        tableState: ratesTableReducer(
            action: action,
            state: state?.tableState
        )
    )
}
