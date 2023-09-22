//
//  FeedImageCell+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Sam on 08/09/2023.
//

import Foundation
import EssentialFeediOS

extension FeedImageCell {
    var isShowLocation: Bool {
        !locationContainer.isHidden
    }
    
    var locationText: String? {
        locationLabel.text
    }
    
    var isShowDescription: Bool {
        !descriptionLabel.isHidden
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
    
    var isShowingImageLoadingIndicator: Bool {
        feedImageContainer.isShimmering
    }
    
    var renderedImage: Data? {
        feedImage.image?.pngData()
    }
    
    var isShowingRetryAction: Bool {
        !retryButton.isHidden
    }
    
    func simulateRetryAction() {
        retryButton.simulateTap()
    }
}
