//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Sam on 14/09/2023.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
