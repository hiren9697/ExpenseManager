//
//  Test.swift
//  ExpensePresentation
//
//  Created by Hirenkumar Fadadu on 17/05/26.
//

import Testing
import Foundation
import ExpenseFeature
@testable import ExpensePresentation

@Suite(.timeLimit(.minutes(1)))
@MainActor
final class SaveExpenseViewModelTests {
    @Test
    func init_setsDateToCurrentDateFromGenerator() async throws {
        let fixedDate = Date(timeIntervalSince1970: 12345)
        await makeSUT(currentDate: fixedDate, action: { sut, spy in
            #expect(sut.date == fixedDate)
        })
    }
    
    @Test
    func save_deliversErrorOnInvalidInputs_andDoesNotRequestSave() async throws {
        // Arrange
        await makeSUT(action: { sut, spy in
            // Act: Empty input
            await sut.save()
            
            // Assert
            #expect(sut.errorMessage == SaveExpenseViewModel.invalidInputMessage)
            #expect(spy.messages.isEmpty)
            
            // Act: Invalid text input
            sut.simulateAmountInput("invalid")
            await sut.save()
            
            // Assert
            #expect(sut.errorMessage == SaveExpenseViewModel.invalidInputMessage)
            #expect(spy.messages.isEmpty)
            
            // Act: Negative input
            sut.simulateAmountInput("-50")
            await sut.save()
            
            // Assert
            #expect(sut.errorMessage == SaveExpenseViewModel.invalidInputMessage)
            #expect(spy.messages.isEmpty)
        })
    }
    
    @Test
    func save_requestsToSaveExpenseWithCorrectMappedInputs() async throws {
        // Arrange
        let currentDateToSubmit = Date(timeIntervalSince1970: 500)
        let amountNumberToSubmit = 250.50
        let amountTextToSubmit = " 250.50 "
        let notesToSubmit = " Launch "
        let expectedDraft = DraftExpense(amount: amountNumberToSubmit, date: currentDateToSubmit, note: notesToSubmit.trimmingCharacters(in: .whitespaces))
        
        await makeSUT(currentDate: currentDateToSubmit, action: { sut, spy in
            sut.simulateAmountInput(amountTextToSubmit)
            sut.simulateNoteInput(notesToSubmit)
            
            // Act
            Task {
                await sut.save()
            }
            await waitForSaveRequestToFire()
            await spy.completeSaveSuccessfullyAndWaitUntilConsumed(at: 0)
            
            // Assert
            #expect(spy.messages == [.save(expectedDraft)])
        })
    }
    
    @Test
    func isLoadingstate_isEnabled_whileSaving() async throws {
        // Arrange
        await makeSUT(action: { sut, spy in
            sut.simulateValidInputs()
            
            // Act
            Task {
                await sut.save()
            }
            await waitForSaveRequestToFire()
            
            // Assert
            #expect(sut.isLoading)
            
            // Act
            await spy.completeSaveSuccessfullyAndWaitUntilConsumed(at: 0)
            
            // Assert
            #expect(sut.isLoading == false)
        })
    }
    
    @Test
    func save_setsErrorState_onSaveError() async throws {
        // Arrange
        await makeSUT(action: { sut, spy in
            sut.simulateValidInputs()
            
            // Assert
            #expect(sut.errorMessage == nil)
            
            // Act
            Task {
                await sut.save()
            }
            await waitForSaveRequestToFire()
            await spy.completeSaveWithErrorAndWaitUntilConsumed(anyNSError(), at: 0)
            
            // Assert
            #expect(sut.errorMessage == SaveExpenseViewModel.saveErrorMessage)
            
            // Act
            Task {
                await sut.save()
            }
            await waitForSaveRequestToFire()
            
            // Assert
            #expect(sut.errorMessage == nil)
            
            // Act
            await spy.completeSaveWithErrorAndWaitUntilConsumed(anyNSError(), at: 1)
            
            // Assert
            #expect(sut.errorMessage == SaveExpenseViewModel.saveErrorMessage)
        })
    }
    
    @Test
    func save_callsCompletion_onSuccessfulSave() async throws {
        // Arrange
        var completedCount = 0
        let completion: SaveExpenseViewModel.Completion = { @MainActor in
            completedCount += 1
        }
        
        await makeSUT(completion: completion, action: { sut, spy in
            sut.simulateValidInputs()
            
            // Act
            Task {
                await sut.save()
            }
            await waitForSaveRequestToFire()
            await spy.completeSaveSuccessfullyAndWaitUntilConsumed(at: 0)
            
            // Assert
            #expect(completedCount == 1)
        })
    }
}

// MARK: - DSL Helpers
extension SaveExpenseViewModel {
    func simulateAmountInput(_ amount: String) {
        self.amountText = amount
    }
    
    func simulateDateInput(_ date: Date) {
        self.date = date
    }
    
    func simulateNoteInput(_ note: String) {
        self.note = note
    }
    
    func simulateValidInputs(amount: String = "100.0", date: Date = Date(timeIntervalSince1970: 100), note: String = "Dinner") {
        self.amountText = amount
        self.date = date
        self.note = note
    }
}
