//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Sam on 14/09/2023.
//

import UIKit

public final class ErrorView: UIView {
    @IBOutlet weak public var errorButton: UIButton!
    
    public var message: String? {
        get { return isVisible ? errorButton.title(for: .normal) : nil }
        set { setMessage(message: newValue) }
    }
    
    private var isVisible: Bool {
        return self.alpha > 0
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
        
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
    
    @IBAction private func hideMessageAnimated() {
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0
        } completion: { completed in
            if completed { self.errorButton.setTitle(nil, for: .normal) }
        }
    }
}
