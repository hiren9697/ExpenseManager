import XCTest
import ExpenseFeature
import ExpensePresentation
@testable import ExpenseUI_UIKit

@MainActor
final class ExpensesViewControllerSnapshotTests: XCTestCase {
    func test_emptyExpenses() async {
        // Arrange
        let sut = makeSUT(loadExpenses: { [] })
        
        // Act
        sut.simulateAppearance()
        await waitForUIRendering()
        
        // Assert
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "EMPTY_EXPENSES_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "EMPTY_EXPENSES_dark")
    }
    
    func test_expensesWithContent() async {
        // Arrange
        let content = expensesWithContent()
        let sut = makeSUT(loadExpenses: { content })
        
        // Act
        sut.simulateAppearance()
        await waitForUIRendering()
        
        // Assert
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "EXPENSES_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "EXPENSES_WITH_CONTENT_dark")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .extraExtraExtraLarge)), named: "EXPENSES_WITH_CONTENT_light_extraExtraExtraLarge")
    }
    
    func test_expensesWithErrorMessage() async {
        // Arrange
        let sut = makeSUT(loadExpenses: { throw NSError(domain: "error", code: 0) })
        
        // Act
        sut.simulateAppearance()
        await waitForUIRendering()
        
        // Assert
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "EXPENSES_WITH_ERROR_MESSAGE_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "EXPENSES_WITH_ERROR_MESSAGE_dark")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .extraExtraExtraLarge)), named: "EXPENSES_WITH_ERROR_MESSAGE_light_extraExtraExtraLarge")
    }
    
    func test_expensesWithLoadingIndicator() async {
        // Arrange
        // Sleep to ensure the load doesn't finish before the snapshot
        let sut = makeSUT(loadExpenses: { 
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            return []
        })
        
        // Act
        sut.simulateAppearance()
        await waitForUIRendering()
        
        // Assert
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "EXPENSES_WITH_LOADING_INDICATOR_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "EXPENSES_WITH_LOADING_INDICATOR_dark")
    }

    // MARK: - Helpers
    private func makeSUT(loadExpenses: @escaping @Sendable () async throws -> [Expense]) -> ExpensesViewController {
        let viewModel = ExpensesViewModel(loadExpenses: loadExpenses)
        let sut = ExpensesViewController(viewModel: viewModel)
        sut.loadViewIfNeeded()
        sut.tableView.showsVerticalScrollIndicator = false
        sut.tableView.showsHorizontalScrollIndicator = false
        return sut
    }
    
    private func waitForUIRendering() async {
        try? await Task.sleep(nanoseconds: 10_000_000)
    }
    
    private func expensesWithContent() -> [Expense] {
        return [
            Expense(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, amount: 120.50, date: Date(timeIntervalSince1970: 1700000000), note: "Grocery Shopping"),
            Expense(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, amount: 15.00, date: Date(timeIntervalSince1970: 1700086400), note: "Lunch with friends\nat the new cafe")
        ]
    }
}
