import Foundation
import Observation
import ExpenseFeature

@MainActor
@Observable
public final class ExpensesViewModel {
    public static let fetchErrorMessage = "Coudn't load expenses"
    private let loadExpenses: LoadExpenses
    public var expenses: [ExpenseViewModel]?
    public var fetchError: String?
    public var isLoading: Bool = false
    
    public init(loadExpenses: @escaping LoadExpenses) {
        self.loadExpenses = loadExpenses
    }
    
    public func fetch() async {
        fetchError = nil
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            expenses = try await loadExpenses().map({ ExpenseViewModel(expense: $0) })
        } catch {
            self.fetchError = Self.fetchErrorMessage
            self.expenses = nil
        }
    }
}
