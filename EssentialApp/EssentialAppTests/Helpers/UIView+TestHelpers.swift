//
//  UIView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Sam on 26/09/2023.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
