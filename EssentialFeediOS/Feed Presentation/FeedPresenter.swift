//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Sam on 11/09/2023.
//

import Foundation
import EssentialFeed

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

struct FeedErrorViewModel {
    let message: String?
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
    private let feedLoading: FeedLoadingView
    private let feedView: FeedView
    private let feedErrorView: FeedErrorView
    
    static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Title for the feed view")
    }
    
    private static var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Error message display when we can't get the feed from server")
    }
    
    init(feedLoading: FeedLoadingView, feedView: FeedView, feedErrorView: FeedErrorView) {
        self.feedLoading = feedLoading
        self.feedView = feedView
        self.feedErrorView = feedErrorView
    }
    
    func didStartLoading() {
        feedLoading.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishSuccess(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        feedLoading.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishFailure(with error: Error) {
        feedErrorView.display(FeedErrorViewModel(message: FeedPresenter.feedLoadError))
        feedLoading.display(FeedLoadingViewModel(isLoading: false))
    }
}
