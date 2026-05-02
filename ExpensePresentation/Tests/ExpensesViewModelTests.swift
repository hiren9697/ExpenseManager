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

final class ExpensesViewModelTests {
    @Test @MainActor func test_fetch_requests_expenses() async {
    }
    
    @MainActor
    private func makeSUT(sourceLocation: SourceLocation = #_sourceLocation,
                         action: (ExpensesViewModel, Spy) -> Void) {
        withMemoryLeakTracking(sourceLocation: sourceLocation, testBody: { tracker in
            let spy = Spy()
            let sut = ExpensesViewModel(loadExpenses: spy.loadExpenses)   
            tracker(spy)
            tracker(sut)
            
            action(sut, spy)
        })
    }
    
    // MARK: - Helpers
    @MainActor
    class Spy: Sendable {
        enum Message { 
            case loadExpenses 
        }
        
        var messages: [Message] = []
        private var loadCompleters: [CheckedContinuation<[Expense], Error>] = []
        
        func loadExpenses() async throws -> [Expense] {
            messages.append(.loadExpenses)
            
            return try await withCheckedThrowingContinuation { continuation in
                loadCompleters.append(continuation)
            }
        }
        
        func completeExpensesLoading(with expenses: [Expense] = [], at index: Int = 0) {
            loadCompleters[index].resume(returning: expenses)
        }
        
        func completeExpensesLoadingWithError(_ error: Error, at index: Int = 0) {
            loadCompleters[index].resume(throwing: error)
        }
    }
}
