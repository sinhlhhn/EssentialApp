//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Sam on 05/09/2023.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    
    @IBOutlet public var locationContainer: UIView!
    @IBOutlet public var locationLabel: UILabel!
    @IBOutlet public var descriptionLabel: UILabel!
    @IBOutlet public var feedImageContainer: UIView!
    @IBOutlet public var feedImage: UIImageView!
    @IBOutlet public var retryButton: UIButton!

    var onRetry: (() -> ())?
    
    @IBAction private func retryButtonTapped() {
        onRetry?()
    }
}
