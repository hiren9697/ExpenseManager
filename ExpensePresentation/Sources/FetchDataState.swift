import Foundation

public enum FetchDataState<T, E> {
    case notInitiated
    case initialRequestInProgress
    case finishedWithData(T)
    case finishedWithError(E)
    case refreshInProgress(T)
    case nextPageInProgress(T)
}

extension FetchDataState: Equatable where T: Equatable, E: Equatable {}
