import XCTest
import ExpenseFeature
import ExpensePresentation
@testable import ExpenseUI_UIKit

@MainActor
final class ExpensesViewControllerSnapshotTests: XCTestCase {
    func test_emptyExpenses() async {
        // Arrange
        let (sut, spy) = makeSUT()
        
        // Act
        sut.simulateAppearance()
        await waitForNetworkRequestToFire()
        await spy.completeExpensesLoadingAndWaitUntilConsumed(with: [])
        await waitForUIUpdate()
        
        // Assert
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "EMPTY_EXPENSES_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "EMPTY_EXPENSES_dark")
    }
    
    func test_expensesWithContent() async {
        // Arrange
        let (sut, spy) = makeSUT()
        
        // Act
        sut.simulateAppearance()
        await waitForNetworkRequestToFire()
        await spy.completeExpensesLoadingAndWaitUntilConsumed(with: expensesWithContent())
        await waitForUIUpdate()
        
        // Assert
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "EXPENSES_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "EXPENSES_WITH_CONTENT_dark")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .extraExtraExtraLarge)), named: "EXPENSES_WITH_CONTENT_light_extraExtraExtraLarge")
    }
    
    func test_expensesWithErrorMessage() async {
        // Arrange
        let (sut, spy) = makeSUT()
        
        // Act
        sut.simulateAppearance()
        await waitForNetworkRequestToFire()
        await spy.completeExpensesLoadingWithErrorAndWaitUntilConsumed(NSError(domain: "error", code: 0))
        await waitForUIUpdate()
        
        // Assert
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "EXPENSES_WITH_ERROR_MESSAGE_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "EXPENSES_WITH_ERROR_MESSAGE_dark")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .extraExtraExtraLarge)), named: "EXPENSES_WITH_ERROR_MESSAGE_light_extraExtraExtraLarge")
    }
    
    func test_expensesWithLoadingIndicator() async {
        // Arrange
        let (sut, _) = makeSUT()
        
        // Act
        sut.simulateAppearance()
        await waitForUIUpdate()
        
        // Assert
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "EXPENSES_WITH_LOADING_INDICATOR_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "EXPENSES_WITH_LOADING_INDICATOR_dark")
    }

    // MARK: - Helpers
    private func makeSUT() -> (ExpensesViewController, Spy) {
        let spy = Spy()
        let viewModel = ExpensesViewModel(loadExpenses: spy.loadExpenses)
        let sut = ExpensesViewController(viewModel: viewModel)
        sut.loadViewIfNeeded()
        sut.tableView.showsVerticalScrollIndicator = false
        sut.tableView.showsHorizontalScrollIndicator = false
        return (sut, spy)
    }
    
    private func waitForNetworkRequestToFire() async {
        await Task.yield()
    }
    
    private func waitForUIUpdate() async {
        await Task.yield()
    }
    
    private func expensesWithContent() -> [Expense] {
        return [
            Expense(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, amount: 120.50, date: Date(timeIntervalSince1970: 1700000000), note: "Grocery Shopping"),
            Expense(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, amount: 15.00, date: Date(timeIntervalSince1970: 1700086400), note: "Lunch with friends\nat the new cafe")
        ]
    }
}
