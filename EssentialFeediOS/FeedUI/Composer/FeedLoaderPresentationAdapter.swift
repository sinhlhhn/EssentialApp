//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Sam on 13/09/2023.
//

import Foundation
import EssentialFeed

class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    private let feedLoader: FeedLoader
    var feedPresenter: FeedPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        feedPresenter?.didStartLoading()
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(images):
                self?.feedPresenter?.didFinishSuccess(with: images)
            case let .failure(error):
                self?.feedPresenter?.didFinishFailure(with: error)
            }
        }
    }
}
