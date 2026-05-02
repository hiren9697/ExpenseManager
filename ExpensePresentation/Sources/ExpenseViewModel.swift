import Foundation
import ExpenseFeature

public struct ExpenseViewModel: Identifiable, Equatable {
    public let expense: Expense
    
    public var id: UUID { expense.id }
    
    public var title: String {
        expense.note ?? "Unknown Expense"
    }
    
    public var amountText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: expense.amount)) ?? "$\(expense.amount)"
    }
    
    public var dateText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: expense.date)
    }
    
    public init(expense: Expense) {
        self.expense = expense
    }
}
