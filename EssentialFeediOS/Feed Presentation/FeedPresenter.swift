//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Sam on 11/09/2023.
//

import Foundation
import EssentialFeed

protocol FeedLoadingView: AnyObject {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feed: [FeedImage])
}

final class FeedPresenter {
    private var feedLoader: FeedLoader
    
    weak var feedLoading: FeedLoadingView?
    var feedView: FeedView?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    func loadFeed() {
        feedLoading?.display(isLoading: true)
        feedLoader.load { [weak self] feed in
            if let items = try? feed.get() {
                self?.feedView?.display(feed: items)
            }
            self?.feedLoading?.display(isLoading: false)
        }
    }
}
