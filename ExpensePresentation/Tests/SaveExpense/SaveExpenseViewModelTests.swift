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
            Task.immediate {
                await sut.save()
            }
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
            Task.immediate {
                await sut.save()
            }
            
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
            Task.immediate {
                await sut.save()
            }
            await spy.completeSaveWithErrorAndWaitUntilConsumed(anyNSError(), at: 0)
            
            // Assert
            #expect(sut.errorMessage == SaveExpenseViewModel.saveErrorMessage)
            
            // Act
            Task.immediate {
                await sut.save()
            }
            
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
            Task.immediate {
                await sut.save()
            }
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


/*
 ### 🧠 The Requirement (spec reference: Capturing Task Handles)

 You want to see exactly how the `taskHandler(task)` mechanism is implemented in the Essential Feed Case Study, what it does under the hood, and why it is written that way.

 ### 🏗️ Recommended Design (The Closure Injection Pattern)

 In the Essential Feed Case Study, `taskHandler` is **not a standalone function**. It is a **closure parameter** (a block of code passed as an argument) injected into a test helper method.

 When testing native `async` code, you often have repetitive setup: spawning the task, waiting for the result, and catching errors. The Essential Feed authors moved all this boilerplate into a helper method called `resultFor`.

 However, they faced a problem: **How do you test task cancellation if the helper method hides the `Task` from the actual test?**

 Their elite solution: The helper method accepts an optional `taskHandler` closure. Right after the helper spawns the `Task`, it passes the `Task` handle into the closure. This acts as an "escape hatch," allowing specific tests (like the cancellation test) to grab the remote control for the task, while other tests can just ignore it.

 ### 💻 Concrete Example

 Here is the exact code from `URLSessionHTTPClientTests.swift` showing the helper method and the test that uses it.

 #### 1. The Helper Method (The Provider)

 Notice how `taskHandler` defaults to an empty closure `{ _ in }`. Most tests don't care about the task handle, so they do nothing.

 ```swift
 // From EssentialFeedTests/Shared API Infra/URLSessionHTTPClientTests.swift

 private func resultFor(
     _ values: (data: Data?, response: URLResponse?, error: Error?)?, 
     taskHandler: (Task<(Data, HTTPURLResponse), Error>) -> Void = { _ in } // 👈 The Closure
 ) async throws -> (Data, HTTPURLResponse) {
     
     // 1. Setup the network stub
     values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
     let sut = makeSUT()
     
     // 2. Spawn the task
     let task = Task {
         return try await sut.get(from: anyURL())
     }
     
     // 3. 🛑 THE ESCAPE HATCH 🛑
     // Pass the task handle back to the test that called this helper
     taskHandler(task)
     
     // 4. Await the final result
     return try await task.value
 }

 ```

 #### 2. The Test (The Consumer)

 Here is the test that ensures network requests can be cancelled. It uses the `taskHandler` to steal the `Task` handle out of the helper method so it can cancel it while the network request is loading.

 ```swift
 func test_cancelGetFromURLTask_cancelsURLRequest() async {
     // 1. Create a variable to hold the stolen task handle
     var task: Task<(Data, HTTPURLResponse), Error>?
     
     // 2. Tell the network stub: "As soon as you start loading, cancel the task"
     URLProtocolStub.onStartLoading { task?.cancel() }
     
     // 3. Call the helper, and pass a closure to grab the task!
     // $0 represents the `task` passed out from the helper method above.
     let receivedError = await resultErrorFor(taskHandler: { task = $0 }) as NSError?
     
     // 4. Assert that the error returned was a cancellation error
     XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
 }

 ```

 *(Note: `resultErrorFor` is just a tiny wrapper around `resultFor` that returns the `Error` instead of the `Data`)*.

 **Why this is a World-Class Pattern:**
 It perfectly balances **DRY (Don't Repeat Yourself)** with **Flexibility**. By injecting a closure, 90% of their tests are incredibly short because the helper handles the `Task` boilerplate. But for the 10% of tests that need surgical precision (like triggering `.cancel()`), the helper effortlessly hands over the controls.
 */
