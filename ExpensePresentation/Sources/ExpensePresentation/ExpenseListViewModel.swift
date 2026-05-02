import Foundation
import Observation
import ExpenseFeature

@MainActor
@Observable
public final class ExpenseListViewModel {
    private let loadExpenses: LoadExpenses
    public var expenses: [ExpenseViewModel] = []
    public var isLoading: Bool = false
    
    public init(loadExpenses: @escaping LoadExpenses) {
        self.loadExpenses = loadExpenses
    }
    
    public func fetch() async {
        isLoading = true
        do {
            expenses = try await loadExpenses().map({ ExpenseViewModel(expense: $0) })
        } catch {
            
        }
    }
}
