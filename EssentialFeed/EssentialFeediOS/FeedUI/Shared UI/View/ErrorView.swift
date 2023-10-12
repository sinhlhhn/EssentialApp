//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Sam on 14/09/2023.
//

import UIKit

public final class ErrorView: UIStackView {
    public lazy var errorButton: UIButton = {
        let errorButton = UIButton()
        errorButton.titleLabel?.numberOfLines = 0
        errorButton.titleLabel?.textAlignment = .center
        return errorButton
    }()
    
    var onHide: (() -> Void)?
    
    public var message: String? {
        get { return isVisible ? errorButton.title(for: .normal) : nil }
        set { setMessage(message: newValue) }
    }
    
    private var isVisible: Bool {
        return self.alpha > 0
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func configure() {
        backgroundColor = .systemRed
        
        configureButton()
        hideMessage()
        
        errorButton.addTarget(self, action: #selector(hideMessageAnimated), for: .touchUpInside)
    }
    
    private func configureButton() {
        addSubview(errorButton)
        errorButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            errorButton.topAnchor.constraint(equalTo: topAnchor),
            bottomAnchor.constraint(equalTo: errorButton.bottomAnchor),
            errorButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            errorButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func hideMessage() {
        errorButton.setTitle("", for: .normal)
        self.alpha = 0
        self.errorButton.isHidden = true
        
    }
    
    private func setMessage(message: String?) {
        if let message = message {
            showMessageAnimated(message: message)
        } else {
            hideMessageAnimated()
        }
    }
    
    private func showMessageAnimated(message: String) {
        self.errorButton.setTitle(message, for: .normal)
        self.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
            self.errorButton.isHidden = false
        }
    }
    
    @objc private func hideMessageAnimated() {
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0
            self.errorButton.isHidden = true
        } completion: { completed in
            if completed { self.hideMessage() }
        }
        
        onHide?()
    }
}
