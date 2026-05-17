//
//  Test.swift
//  ExpensePresentation
//
//  Created by Hirenkumar Fadadu on 17/05/26.
//

import Testing
import ExpensePresentation

struct SaveExpenseViewModelTests {
    @Test
    func save_setsErrorState_onInvalidInputs() throws {
        
    }
    
    @Test
    func save_requestsToSaveExpenseWithCorrectInputs_onValidInputs() throws {
        
    }
    
    @Test
    func save_setsErrorState_onSaveError() throws {
        
    }
    
    @Test
    func save_callsCompletion_onSuccessfulSave() throws {
        
    }
    
    // MARK: - Helpers
    @MainActor
    private func makeSUT(completion: @escaping SaveExpenseViewModel.Completion = {},
                         sourceLocation: SourceLocation = #_sourceLocation,
                         action: (SaveExpenseViewModel, Spy) async -> Void) async {
        await withMemoryLeakTracking(sourceLocation: sourceLocation, testBody: { tracker in
            let spy = Spy()
            let sut = SaveExpenseViewModel(saveExpense: spy.save,
                                           completion: completion)   
            await tracker(spy, sut)
            await action(sut, spy)
        })
    } 
}
