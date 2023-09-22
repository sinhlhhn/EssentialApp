//
//  UIRefreshController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Sam on 08/09/2023.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
