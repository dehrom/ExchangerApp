import ReSwift

extension Store {
    func dispatch(action: Action, in queue: DispatchQueue = .main) {
        queue.async {
            mainStore.dispatch(action)
        }
    }
}
