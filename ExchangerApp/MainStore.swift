import ReSwift

let mainStore = Store<MainState>(
    reducer: mainReducer(action:state:),
    state: .initial
)
