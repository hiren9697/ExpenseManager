//
//  SaveExpenseViewModelTests+Helpers.swift
//  ExpensePresentation
//
//  Created by Hirenkumar Fadadu on 17/05/26.
//

import Testing
import Foundation
@testable import ExpensePresentation

extension SaveExpenseViewModelTests {
    @MainActor
    func makeSUT(currentDate: Date = .now,
                 completion: @escaping SaveExpenseViewModel.Completion = {},
                 sourceLocation: SourceLocation = #_sourceLocation,
                 action: (SaveExpenseViewModel, Spy) async -> Void) async {
        await withMemoryLeakTracking(sourceLocation: sourceLocation, testBody: { tracker in
            let spy = Spy()
            let sut = SaveExpenseViewModel(saveExpense: spy.save,
                                           currentDate: currentDate,
                                           completion: completion)   
            await tracker(spy, sut)
            
            await action(sut, spy)
        })
    }
    
    func waitForSaveRequestToFire() async {
        await Task.yield()
    }
    
    func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
}
