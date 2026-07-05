import Testing
import UIKit
@testable import ExpenseFeature
@testable import ExpensePresentation
@testable import ExpenseUI_UIKit

@Suite(.timeLimit(.minutes(1)))
@MainActor
final class SaveExpenseViewControllerTests {
    @Test
    func initialInputFieldsValues_areConfiguredCorrectly() async {
        let testDate = Date(timeIntervalSince1970: 1700000000)
        await makeSUT(currentDate: testDate) { sut, spy in
            // Arrange & Act
            sut.simulateAppearance()
            
            // Assert
            #expect(sut.amountText.isEmpty, "Expected amount to be empty on init")
            #expect(sut.noteText.isEmpty, "Expected note to be empty on init")
            #expect(sut.dateText == sut.formattedDate(testDate), "Expected date to match injected current date")
            #expect(spy.messages.isEmpty, "Expected no save requests on init")
        }
    }
    
    @Test
    func save_showsValidationError_onInvalidAmount() async {
        await makeSUT { sut, spy in
            // Arrange
            sut.simulateAppearance()
            
            // Act
            sut.simulateAmountInput("")
            sut.simulateSaveTap()
            
            // Assert
            await assertEventually { sut.errorMessage == SaveExpenseViewModel.invalidInputMessage }
            
            // Act
            sut.simulateAmountInput("-15.0")
            sut.simulateSaveTap()
            
            // Assert
            await assertEventually { sut.errorMessage == SaveExpenseViewModel.invalidInputMessage }
            #expect(spy.messages.isEmpty, "Expected no save requests for invalid inputs")
        }
    }
    
    @Test
    func save_requestsSave_onValidInputsWithOptionalNote() async {
        await makeSUT { sut, spy in
            // Arrange
            sut.simulateAppearance()
            sut.simulateAmountInput("45.50")
            // Note is intentionally left empty to satisfy the optional spec
            
            // Act
            sut.simulateSaveTap()
            
            // Assert
            await assertEventually { spy.messages == [.save] }
        }
    }
    
    @Test
    func save_managesLoadingState_whileSaving() async {
        await makeSUT { sut, spy in
            // Arrange
            sut.simulateAppearance()
            sut.simulateAmountInput("100.0")
            
            // Act: Tap save, wait for the network/store boundary to be hit
            sut.simulateSaveTap()
            await assertEventually { spy.messages == [.save] }
            
            // Assert: Loader should be visible while suspended
            #expect(sut.isShowingLoadingIndicator)
            
            // Act: Complete the request
            await spy.completeSaveAndWaitUntilConsumed(at: 0)
            
            // Assert: Loader hides
            await assertEventually { !sut.isShowingLoadingIndicator }
        }
    }
    
    @Test
    func save_showsErrorMessage_onStoreFailure() async {
        await makeSUT { sut, spy in
            // Arrange
            sut.simulateAppearance()
            sut.simulateAmountInput("100.0")
            
            // Act
            sut.simulateSaveTap()
            await assertEventually { spy.messages == [.save] }
            
            await spy.completeSaveWithErrorAndWaitUntilConsumed(anyNSError(), at: 0)
            
            // Assert
            await assertEventually { sut.errorMessage == SaveExpenseViewModel.saveErrorMessage }
        }
    }
    
    @Test
    func save_triggersCompletion_onSuccess() async {
        var completionCallCount = 0
        await makeSUT(completion: { completionCallCount += 1 }) { sut, spy in
            // Arrange
            sut.simulateAppearance()
            sut.simulateAmountInput("50.0")
            
            // Act
            sut.simulateSaveTap()
            await assertEventually { spy.messages == [.save] }
            
            await spy.completeSaveAndWaitUntilConsumed(at: 0)
            
            // Assert
            await assertEventually { completionCallCount == 1 }
        }
    }

    @MainActor
    private func makeSUT(
        currentDate: Date = Date(),
        completion: @escaping () -> Void = {},
        sourceLocation: SourceLocation = #_sourceLocation,
        action: @MainActor (SaveExpenseViewController, SaveExpenseSpy) async -> Void
    ) async {
        await withMemoryLeakTracking(sourceLocation: sourceLocation, testBody: { tracker in
            let spy = SaveExpenseSpy()
            
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            let formatDate: (Date) -> String = { formatter.string(from: $0) }
            
            let sut = SaveExpenseViewControllerComposer.compose(
                saveExpense: spy.saveExpense,
                currentDate: currentDate,
                formatDate: formatDate,
                completion: completion
            )
            await tracker(spy, sut)
            await action(sut, spy)
            try? await spy.cancelPendingRequests()
        })
    }
}
