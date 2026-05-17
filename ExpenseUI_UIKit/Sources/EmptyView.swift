import UIKit

public final class EmptyView: UIView {
    public let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    public let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    public let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Retry", for: .normal)
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        return stackView
    }()
    
    public var onRetry: (() -> Void)?
    
    public init(image: UIImage? = nil, message: String? = nil) {
        super.init(frame: .zero)
        setupView()
        setupContent(image: image, message: message)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    public func setupContent(image: UIImage?, message: String?) {
        imageView.image = image
        messageLabel.text = message
        imageView.isHidden = image == nil
        messageLabel.isHidden = message == nil
    }
    
    private func setupView() {
        addSubview(stackView)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(retryButton)
        
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
}
