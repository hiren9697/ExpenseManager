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
    func save_requestsToSaveExpenseWithCorrectInputs_onValidInputs() async throws {
        // Arrange
        await makeSUT(action: { sut, spy in
            let draft1 = DraftExpense(amount: 100.0, date: Date(timeIntervalSince1970: 100), note: "Dinner")
            let draft2 = DraftExpense(amount: 50.0, date: Date(timeIntervalSince1970: 200), note: nil)
            
            // Act
            Task {
                await sut.save(draft: draft1)
            }
            await waitForSaveRequestToFire()
            await spy.completeSaveSuccessfullyAndWaitUntilConsumed(at: 0)
            
            // Assert
            #expect(spy.messages == [.save(draft1)])
            
            // Act
            Task {
                await sut.save(draft: draft2)
            }
            await waitForSaveRequestToFire()
            await spy.completeSaveSuccessfullyAndWaitUntilConsumed(at: 1)
            
            // Assert
            #expect(spy.messages == [
                .save(draft1),
                .save(draft2)
            ])
        })
    }
    
    @Test
    func isLoadingstate_isEnabled_whileSaving() async throws {
        // Arrange
        await makeSUT(action: { sut, spy in
            let draft = DraftExpense(amount: 100.0, date: Date(timeIntervalSince1970: 100), note: "Dinner")
            
            // Act
            Task {
                await sut.save(draft: draft)
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
            let draft = DraftExpense(amount: 100.0, date: Date(timeIntervalSince1970: 100), note: "Dinner")
            
            // Assert
            #expect(sut.errorMessage == nil)
            
            // Act
            Task {
                await sut.save(draft: draft)
            }
            await waitForSaveRequestToFire()
            await spy.completeSaveWithErrorAndWaitUntilConsumed(anyNSError(), at: 0)
            
            // Assert
            #expect(sut.errorMessage == SaveExpenseViewModel.saveErrorMessage)
            
            // Act
            Task {
                await sut.save(draft: draft)
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
            let draft = DraftExpense(amount: 100.0, date: Date(timeIntervalSince1970: 100), note: "Dinner")
            
            // Act
            Task {
                await sut.save(draft: draft)
            }
            await waitForSaveRequestToFire()
            await spy.completeSaveSuccessfullyAndWaitUntilConsumed(at: 0)
            
            // Assert
            #expect(completedCount == 1)
        })
    }
}
