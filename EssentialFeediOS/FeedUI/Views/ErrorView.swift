//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Sam on 14/09/2023.
//

import UIKit

public final class ErrorView: UIView {
    @IBOutlet weak var errorLabel: UILabel!
    
    public var message: String? {
        get { return errorLabel.text }
        set { errorLabel.text = newValue }
    }
}
