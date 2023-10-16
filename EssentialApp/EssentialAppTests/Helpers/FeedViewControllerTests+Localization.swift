//
//  FeedViewControllerTests+Localization.swift
//  EssentialFeediOSTests
//
//  Created by Sam on 12/09/2023.
//

import Foundation
import XCTest
import EssentialFeed

extension FeedUIIntegrationTests {
    
    var loadError: String {
        FeedPresenter.feedLoadError
    }
    
    var feedTitle: String {
        FeedPresenter.title
    }
    
    var commentsTitle: String {
        ImageCommentsPresenter.title
    }
}
