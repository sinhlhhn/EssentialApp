//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Sam on 11/09/2023.
//

import Foundation
import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
    private var feedLoader: FeedLoader
    
    var feedLoading: FeedLoadingView?
    var feedView: FeedView?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    func loadFeed() {
        feedLoading?.display(FeedLoadingViewModel(isLoading: true))
        feedLoader.load { [weak self] feed in
            if let items = try? feed.get() {
                self?.feedView?.display(FeedViewModel(feed: items))
            }
            self?.feedLoading?.display(FeedLoadingViewModel(isLoading: false))
        }
    }
}
