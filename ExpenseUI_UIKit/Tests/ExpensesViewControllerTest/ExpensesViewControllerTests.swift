//
//  File.swift
//  ExpenseUI_UIKit
//
//  Created by Hirenkumar Fadadu on 03/05/26.
//

import UIKit
import Testing
import ExpensePresentation
import ExpenseFeature
import ExpenseUI_UIKit

@Suite(.timeLimit(.minutes(1)))
@MainActor
final class ExpensesViewControllerTests {
    @Test
    func loadExpensesAction_requestsExpenses() async {
        // Arrange
        await makeSUT(action: { sut, spy in
            // Assert
            #expect(spy.messages.isEmpty)
            
            // Act
            sut.simulateAppearance()
            await waitForNetworkRequestToFire()
            await spy.completeExpensesLoadingAndWaitUntilConsumed(with: [], at: 0)

            // Assert
            #expect(spy.messages == [Spy.Message.loadExpenses])
            
            // Act
            sut.simulateAppearance()
            await waitForNetworkRequestToFire()
            
            // Assert
            #expect(spy.messages == [Spy.Message.loadExpenses])
            
            // Act
            sut.simulateUserInitiatedReload()
            await waitForNetworkRequestToFire()
            await spy.completeExpensesLoadingAndWaitUntilConsumed(with: [], at: 1)
            
            // Assert
            #expect(spy.messages == [Spy.Message.loadExpenses, Spy.Message.loadExpenses])
            
            // Act
            sut.simulateUserInitiatedReload()
            await waitForNetworkRequestToFire()
            await spy.completeExpensesLoadingAndWaitUntilConsumed(with: [], at: 2)
            
            // Assert
            #expect(spy.messages == [Spy.Message.loadExpenses, Spy.Message.loadExpenses, Spy.Message.loadExpenses])
        })
    }
    
    @Test
    func loader_isVisible_whileFetchingExpenses() async {
        // Arrange
        await makeSUT(action: { sut, spy in
            // Act
            sut.simulateAppearance()
            await waitForNetworkRequestToFire()
            
            // Assert
            #expect(sut.isShowingLoadingIndicator)
            
            // Act
            await spy.completeExpensesLoadingAndWaitUntilConsumed(with: [], at: 0)
            
            // Assert
            #expect(!sut.isShowingLoadingIndicator)
            
            // Act
            sut.simulateUserInitiatedReload()
            await waitForNetworkRequestToFire()
            
            // Assert
            #expect(sut.isShowingLoadingIndicator)
            
            // Act
            await spy.completeExpensesLoadingAndWaitUntilConsumed(with: [], at: 1)
            
            // Assert
            #expect(!sut.isShowingLoadingIndicator)
            
            // Act
            sut.simulateUserInitiatedReload()
            await waitForNetworkRequestToFire()
            
            // Assert
            #expect(sut.isShowingLoadingIndicator)
            
            // Act
            await spy.completeExpensesLoadingWithErrorAndWaitUntilConsumed(anyNSError(), at: 2)
            
            // Assert
            #expect(!sut.isShowingLoadingIndicator)
        })
    }
    
    @Test
    func fetchExpense_rendersSuccessfullyFetchedExpenses() async {
        // Arrange
        await makeSUT(action: { sut, spy in
            let expense0 = makeExpense(amount: 10, note: "first expense description")
            let expense1 = makeExpense(amount: 20, note: nil)
            let expense2 = makeExpense(amount: 30, note: "third expense description")
            let expense3 = makeExpense(amount: 40, note: "fourth expense description")
            
            // Act
            sut.simulateAppearance()
            await waitForNetworkRequestToFire()
            
            // Assert
            assertThat(sut, isRendering: [])
            
            // Act
            await spy.completeExpensesLoadingAndWaitUntilConsumed(with: [expense0, expense1], at: 0)
            await waitForUIUpdate()
            
            // Assert
            assertThat(sut, isRendering: [expense0, expense1])
            
            // Act
            sut.simulateUserInitiatedReload()
            await waitForNetworkRequestToFire()
            await spy.completeExpensesLoadingAndWaitUntilConsumed(with: [expense0, expense1, expense2, expense3], at: 1)
            await waitForUIUpdate()
            
            // Assert
            assertThat(sut, isRendering: [expense0, expense1, expense2, expense3])
        })
    }
    
    @Test
    func fetchExpenses_showErrorView_onError() async {
        // Arrange
        await makeSUT(action: { sut, spy in
            // Act
            sut.simulateAppearance()
            await waitForNetworkRequestToFire()
            await spy.completeExpensesLoadingWithErrorAndWaitUntilConsumed(anyNSError(), at: 0)
            await waitForUIUpdate()
            
            // Assert
            assertDataFetchErrorViewDisplayed(sut)
            
            // Act
            sut.simulateErrorViewRetryAction()
            await waitForNetworkRequestToFire()
            
            // Assert
            #expect(spy.messages == [.loadExpenses, .loadExpenses])
        })
    }
    
    @Test
    func fetchExpenses_showEmptyView_onEmptyData() async {
        // Arrange
        await makeSUT(action: { sut, spy in
            // Act
            sut.simulateAppearance()
            await waitForNetworkRequestToFire()
            await spy.completeExpensesLoadingAndWaitUntilConsumed(with: [], at: 0)
            await waitForUIUpdate()
            
            // Assert
            assertDataFetchEmptyViewDisplayed(sut)
            
            // Act
            sut.simulateEmptyViewRetryAction()
            await waitForNetworkRequestToFire()
            
            // Assert
            #expect(spy.messages == [.loadExpenses, .loadExpenses])
        })
    }
    
    @MainActor
    private func makeSUT(sourceLocation: SourceLocation = #_sourceLocation,
                         action: @MainActor (ExpensesViewController, Spy) async -> Void) async {
        await withMemoryLeakTracking(sourceLocation: sourceLocation, testBody: { tracker in
            let spy = Spy()
            let sut = ExpensesViewControllerComposer.compose(loadExpenses: spy.loadExpenses)   
            await tracker(spy, sut)
            
            await action(sut, spy)
            
            try? await spy.cancelPendingRequests()
        })
    }
}
