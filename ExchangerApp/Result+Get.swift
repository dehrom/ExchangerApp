import Result

extension Result {
    func get(
        ifSuccess: (T) throws -> Void,
        ifFailure: ((Error) throws -> Void)? = nil
    ) rethrows {
        switch self {
        case let .success(obj):
            try ifSuccess(obj)
        case let .failure(error):
            try ifFailure?(error)
        }
    }
}
