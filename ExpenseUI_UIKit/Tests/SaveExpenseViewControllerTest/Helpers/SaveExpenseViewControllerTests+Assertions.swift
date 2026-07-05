import Testing
@testable import ExpensePresentation
@testable import ExpenseUI_UIKit

extension SaveExpenseViewControllerTests {
    func assertErrorMessage(_ sut: SaveExpenseViewController, equals message: String, sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(sut.errorMessage == message, "Expected error message to be \(message)", sourceLocation: sourceLocation)
    }
}
