import Foundation
import Observation
import ExpenseFeature

@MainActor
@Observable
public final class ExpensesViewModel {
    public static let fetchError = "Coudn't load expenses"
    private let loadExpenses: LoadExpenses
    public var expenses: [ExpenseViewModel]?
    public var error: String?
    public var isLoading: Bool = false
    
    public init(loadExpenses: @escaping LoadExpenses) {
        self.loadExpenses = loadExpenses
    }
    
    public func fetch() async {
        error = nil
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            expenses = try await loadExpenses().map({ ExpenseViewModel(expense: $0) })
        } catch {
            self.error = Self.fetchError
            self.expenses = nil
        }
    }
}
