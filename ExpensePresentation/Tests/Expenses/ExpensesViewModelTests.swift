//
//  File.swift
//  ExpensePresentation
//
//  Created by Hirenkumar Fadadu on 02/05/26.
//

import Foundation
import ExpenseFeature
import ExpensePresentation
import Testing

@Suite(.timeLimit(.minutes(1)))
@MainActor
final class ExpensesViewModelTests {
    // MARK: - Tests
    @Test 
    func fetch_requests_expenses() async {
        // Arrange
        await makeSUT(action: { sut, spy in
            // Act
            Task {
                await sut.load()
            }
            await waitForFetchRequestToFire() 
            await spy.completeExpensesLoadingAndWaitUntilConsumed(with: [], at: 0)
            
            // Assert   
            #expect(spy.messages == [.loadExpenses])

            // Act
            Task { await sut.load() }
            await waitForFetchRequestToFire()
            await spy.completeExpensesLoadingAndWaitUntilConsumed(with: [], at: 1)
            
            // Assert   
            #expect(spy.messages == [.loadExpenses, .loadExpenses])
        })
    }

    @Test
    func isLoadingstate_isEnabled_whileFetching() async throws {
        // Arrange
        await makeSUT(action: { sut, spy in
            // Act
            Task {
                await sut.load()
            }
            await waitForFetchRequestToFire() 
            
            // Assert
            #expect(sut.isLoading)
            
            // Act
            await spy.completeExpensesLoadingAndWaitUntilConsumed(with: [], at: 0)
            
            // Assert
            #expect(sut.isLoading == false)

            // Act
            Task {
                await sut.load()
            }
            await waitForFetchRequestToFire() 
            
            // Assert
            #expect(sut.isLoading)
            
            // Act
            await spy.completeExpensesLoadingAndWaitUntilConsumed(with: [], at: 1)
            
            // Assert
            #expect(sut.isLoading == false)
        })
    }
    
    @Test
    func fetch_setsError_onReceivingErrorFromLoader() async throws {
        // Arrange
        await makeSUT(action: { sut, spy in
            // Assert
            #expect(sut.fetchError == nil)
            
            // Act
            Task {
                await sut.load()
            }
            await waitForFetchRequestToFire()
            await spy.completeExpensesLoadingWithErrorAndWaitUntilConsumed(anyNSError(), at: 0)
            
            // Assert
            #expect(sut.fetchError == ExpensesViewModel.fetchErrorMessage)

            // Act
            Task {
                await sut.load()
            }
            await waitForFetchRequestToFire()

            // Assert
            #expect(sut.fetchError == nil)
            
            // Act
            await spy.completeExpensesLoadingWithErrorAndWaitUntilConsumed(anyNSError(), at: 1)
            
            // Assert
            #expect(sut.fetchError == ExpensesViewModel.fetchErrorMessage)
        })
    }
    
    @Test
    func fetch_setsExpenses_onSuccessResponse() async throws {
        // Arrange
        let firstResult = [Expense(id: UUID(), amount: 100, date: Date(), note: "Lunch")]
        let firstResultViewModels = firstResult.map({ ExpenseViewModel(expense: $0) })
        let thirdResult = [Expense(id: UUID(), amount: 500, date: Date(), note: "Medicines"),
                           Expense(id: UUID(), amount: 200, date: Date(), note: "Taxi")]
        let thirdResultViewModels = thirdResult.map({ ExpenseViewModel(expense: $0) })
        await makeSUT { sut, spy in
            // Act
            Task { await sut.load() }
            await waitForFetchRequestToFire()
            await spy.completeExpensesLoadingAndWaitUntilConsumed(with: firstResult, at: 0)
            
            // Assert
            #expect(sut.expenses == firstResultViewModels)

            // Act
            Task { await sut.load() }
            await waitForFetchRequestToFire()
            await spy.completeExpensesLoadingWithErrorAndWaitUntilConsumed(anyNSError(), at: 1)
            
            // Assert
            #expect(sut.expenses == nil)
            
            // Act
            Task { await sut.load() }
            await waitForFetchRequestToFire()
            await spy.completeExpensesLoadingAndWaitUntilConsumed(with: thirdResult, at: 2)
            
            // Assert
            #expect(sut.expenses == thirdResultViewModels)
        }
    }
    
    // MARK: - Helpers
    @MainActor
    private func makeSUT(sourceLocation: SourceLocation = #_sourceLocation,
                         action: (ExpensesViewModel, Spy) async -> Void) async {
        await withMemoryLeakTracking(sourceLocation: sourceLocation, testBody: { tracker in
            let spy = Spy()
            let sut = ExpensesViewModel(loadExpenses: spy.loadExpenses)   
            await tracker(spy, sut)
            
            await action(sut, spy)
        })
    }
}
