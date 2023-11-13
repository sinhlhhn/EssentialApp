//
//  UIView+Container.swift
//  EssentialFeediOS
//
//  Created by Sam on 12/10/2023.
//

import UIKit

extension UIView {
    func makeContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        container.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: container.topAnchor),
            bottomAnchor.constraint(equalTo: container.bottomAnchor),
            leadingAnchor.constraint(equalTo: container.leadingAnchor),
            trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
        
        return container
    }
}
