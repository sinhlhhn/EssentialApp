//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Sam on 08/09/2023.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
