//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Sam on 05/09/2023.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let feedImageContainer = UIView()
    public let feedImage = UIImageView()
    private(set) public lazy var retryButton: UIButton = {
            let button = UIButton()
            button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
            return button
        }()
    
    var onRetry: (() -> ())?
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
}
