import UIKit
@testable import ExpenseUI_UIKit

extension SaveExpenseViewController {
    func simulateAppearance() {
        if !isViewLoaded { loadViewIfNeeded() }
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func simulateAmountInput(_ text: String) {
        amountTextField.text = text
        amountTextField.simulate(event: .editingChanged)
    }
    
    func simulateSaveTap() {
        saveButton.simulate(event: .touchUpInside)
    }
    
    var amountText: String { amountTextField.text ?? "" }
    var noteText: String { noteTextField.text ?? "" }
    var dateText: String { dateTextField.text ?? "" }
    
    var isShowingLoadingIndicator: Bool {
        return !activityIndicator.isHidden && activityIndicator.isAnimating
    }
    
    var errorMessage: String? {
        return errorLabel.isHidden ? nil : errorLabel.text
    }
    
    func formattedDate(_ date: Date) -> String {
        return formatDate?(date) ?? ""
    }
}
