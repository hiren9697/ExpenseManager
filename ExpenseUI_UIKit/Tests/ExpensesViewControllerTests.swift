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
            spy.completeExpensesLoading(with: [], at: 0)
            await Task.yield()

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
            spy.completeExpensesLoading(with: [], at: 1)
            await Task.yield()
            
            // Assert
            #expect(spy.messages == [Spy.Message.loadExpenses, Spy.Message.loadExpenses])
            
            // Act
            sut.simulateUserInitiatedReload()
            await Task.yield()
            spy.completeExpensesLoading(with: [], at: 2)
            await Task.yield()
            
            // Assert
            #expect(spy.messages == [Spy.Message.loadExpenses, Spy.Message.loadExpenses, Spy.Message.loadExpenses])
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
        })
    }
    
    // MARK: - Helpers
    @MainActor
    class Spy: Sendable {
        enum Message { 
            case loadExpenses 
        }
        
        var messages: [Message] = []
        
        private var requests: [(stream: AsyncThrowingStream<[Expense], Error>,
                                continuation: AsyncThrowingStream<[Expense], Error>.Continuation)] = []
        
        func loadExpenses() async throws -> [Expense] {
            messages.append(.loadExpenses)
            
            let (stream, continuation) = AsyncThrowingStream<[Expense], Error>.makeStream()
            requests.append((stream, continuation))
            
            for try await result in stream {
                return result
            }
            
            throw CancellationError()
        }
        
        func completeExpensesLoading(with expenses: [Expense] = [], at index: Int = 0) {
            requests[index].continuation.yield(expenses)
            requests[index].continuation.finish()
        }
        
        func completeExpensesLoadingWithError(_ error: Error, at index: Int = 0) {
            requests[index].continuation.finish(throwing: error)
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
