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
    // MARK: - Tests
    @Test
    func loadExpensesAction_requestsExpenses() async {
        // Arrange
        await makeSUT(action: { sut, spy in
            // Assert
            #expect(spy.messages.isEmpty)
            
            // Act
            sut.simulateAppearance()
            await Task.yield()
            await spy.completeExpensesLoading(with: [], at: 0)

            // Assert
            #expect(spy.messages == [Spy.Message.loadExpenses])
            
            // Act
            sut.simulateAppearance()
            await Task.yield()
            
            // Assert
            #expect(spy.messages == [Spy.Message.loadExpenses])
            
            // Act
            sut.simulateUserInitiatedReload()
            await Task.yield()
            await spy.completeExpensesLoading(with: [], at: 1)
            
            // Assert
            #expect(spy.messages == [Spy.Message.loadExpenses, Spy.Message.loadExpenses])
            
            // Act
            sut.simulateUserInitiatedReload()
            await Task.yield()
            await spy.completeExpensesLoading(with: [], at: 2)
            
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
            await Task.yield()
            
            // Assert
            #expect(sut.isShowingLoadingIndicator)
            
            // Act
            await spy.completeExpensesLoading(with: [], at: 0)
            
            // Assert
            #expect(!sut.isShowingLoadingIndicator)
            
            // Act
            sut.simulateUserInitiatedReload()
            await Task.yield()
            
            // Assert
            #expect(sut.isShowingLoadingIndicator)
            
            // Act
            await spy.completeExpensesLoading(with: [], at: 1)
            
            // Assert
            #expect(!sut.isShowingLoadingIndicator)
            
            // Act
            sut.simulateUserInitiatedReload()
            await Task.yield()
            
            // Assert
            #expect(sut.isShowingLoadingIndicator)
            
            // Act
            await spy.completeExpensesLoadingWithError(anyNSError(), at: 2)
            
            // Assert
            #expect(!sut.isShowingLoadingIndicator)
        })
    }
    
    @MainActor
    private func makeSUT(sourceLocation: SourceLocation = #_sourceLocation,
                         action: @MainActor (ExpensesViewController, Spy) async -> Void) async {
        await withMemoryLeakTracking(sourceLocation: sourceLocation, testBody: { tracker in
            let spy = Spy()
            let sut = ExpensesViewControllerComposer.compose(viewModel: ExpensesViewModel(loadExpenses: spy.loadExpenses))   
            await tracker(spy, sut)
            
            await action(sut, spy)
            
            try? await spy.cancelPendingRequests()
        })
    }
    
    // MARK: - Helpers
    @MainActor
    class Spy: Sendable {
        private enum AsyncResult {
            case success
            case failure
            case cancelled
        }
        enum Message { 
            case loadExpenses 
        }
        private struct Request {
            let param: Message
            let stream: AsyncThrowingStream<[Expense], Error>
            let continuation: AsyncThrowingStream<[Expense], Error>.Continuation
            var result: AsyncResult?
        }
        private struct NoResponse: Error {}
        private struct Timeout: Error {}
        
        private var requests: [Request] = []
        
        var messages: [Message] { requests.map(\.param) }
        
        func loadExpenses() async throws -> [Expense] {
            let index = requests.count
            let (stream, continuation) = AsyncThrowingStream<[Expense], Error>.makeStream()
            requests.append(Request(param: Message.loadExpenses, stream: stream, continuation: continuation))
            
            do {
                for try await result in stream {
                    try Task.checkCancellation()
                    requests[index].result = .success
                    return result
                }
                
                try Task.checkCancellation()
                
                throw NoResponse()
            } catch {
                requests[index].result = Task.isCancelled ? .cancelled : .failure
                throw error
            }
        }
        
        func completeExpensesLoading(with expenses: [Expense] = [], at index: Int = 0) async {
            requests[index].continuation.yield(expenses)
            requests[index].continuation.finish()
            while requests[index].result == nil { await Task.yield() }
        }
        
        func completeExpensesLoadingWithError(_ error: Error, at index: Int = 0) async {
            requests[index].continuation.finish(throwing: error)
            while requests[index].result == nil { await Task.yield() }
        }
        
        /*
        func result(at index: Int, timeout: TimeInterval = 1) async throws -> AsyncResult {
            let maxDate = Date() + timeout
            
            while Date() <= maxDate {
                if let result = requests[index].result {
                    return result
                }
                
                await Task.yield()
            }
            
            throw Timeout()
        }
        
        */
        func cancelPendingRequests() async throws {
            for (index, request) in requests.enumerated() where request.result == nil {
                request.continuation.finish(throwing: CancellationError())
                
                while requests[index].result == nil { await Task.yield() }
            }
        }
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
}

extension ExpensesViewController {
    func simulateAppearance() {
		if !isViewLoaded {
			loadViewIfNeeded()
			prepareForFirstAppearance()
		}
		
		beginAppearanceTransition(true, animated: false)
		endAppearanceTransition()
	}
	
	private func prepareForFirstAppearance() {
		// setSmallFrameToPreventRenderingCells()
		replaceRefreshControlWithFakeForiOS17PlusSupport()
	}
	
    /*
	private func setSmallFrameToPreventRenderingCells() {
		tableView.frame = CGRect(x: 0, y: 0, width: 390, height: 1)
	}
     */
	
	private func replaceRefreshControlWithFakeForiOS17PlusSupport() {
		let fakeRefreshControl = FakeUIRefreshControl()
		
		refreshControl?.allTargets.forEach { target in
			refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
				fakeRefreshControl.addTarget(target, action: Selector(action), for: .valueChanged)
			}
		}
		
		refreshControl = fakeRefreshControl
	}
	
	private class FakeUIRefreshControl: UIRefreshControl {
		private var _isRefreshing = false
		
		override var isRefreshing: Bool { _isRefreshing }
		
		override func beginRefreshing() {
			_isRefreshing = true
		}
		
		override func endRefreshing() {
			_isRefreshing = false
		}
	}
	
	func simulateUserInitiatedReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
}

extension UIRefreshControl {
	func simulatePullToRefresh() {
		simulate(event: .valueChanged)
	}
}

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
