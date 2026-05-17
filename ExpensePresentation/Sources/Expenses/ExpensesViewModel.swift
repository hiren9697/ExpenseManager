import Foundation
import Observation
import ExpenseFeature

@MainActor
@Observable
public final class ExpensesViewModel {
    public static let fetchErrorMessage = "Coudn't load expenses"
    private let loadExpenses: LoadExpenses
    public var state: FetchDataState<[ExpenseViewModel], String> = .notInitiated
    
    public var expenses: [ExpenseViewModel]? {
        switch state {
        case .notInitiated, .initialRequestInProgress, .finishedWithError:
            return nil
        case .finishedWithData(let data), .refreshInProgress(let data), .nextPageInProgress(let data):
            return data
        }
    }
    
    public var fetchError: String? {
        if case .finishedWithError(let error) = state {
            return error
        }
        return nil
    }
    
    public var isLoading: Bool {
        switch state {
        case .initialRequestInProgress, .refreshInProgress, .nextPageInProgress:
            return true
        default:
            return false
        }
    }
    
    public init(loadExpenses: @escaping LoadExpenses) {
        self.loadExpenses = loadExpenses
    }
    
    public func load() async {
        state = .initialRequestInProgress
        await fetchExpenses()
    }
    
    public func refresh() async {
        if let currentExpenses = expenses {
            state = .refreshInProgress(currentExpenses)
        } else {
            state = .refreshInProgress([])
        }
        await fetchExpenses()
    }
    
    private func fetchExpenses() async {
        do {
            let loadedExpenses = try await loadExpenses().map({ ExpenseViewModel(expense: $0) })
            state = .finishedWithData(loadedExpenses)
        } catch {
            state = .finishedWithError(Self.fetchErrorMessage)
        }
    }
}
