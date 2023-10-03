//
//  FeedResourcePresenter.swift
//  EssentialFeed
//
//  Created by Sam on 03/10/2023.
//

import Foundation

public final class FeedResourcePresenter {
    private let feedLoading: FeedLoadingView
    private let feedView: FeedView
    private let feedErrorView: FeedErrorView
    
    public init(feedLoading: FeedLoadingView, feedView: FeedView, feedErrorView: FeedErrorView) {
        self.feedLoading = feedLoading
        self.feedView = feedView
        self.feedErrorView = feedErrorView
    }
    
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Title for the feed view")
    }
    
    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Error message display when we can't get the feed from server")
    }
    
    public func didStartLoading() {
        feedErrorView.display(.noError)
        feedLoading.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishSuccess(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        feedLoading.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishFailure(with error: Error) {
        feedErrorView.display(.error(message: feedLoadError))
        feedLoading.display(FeedLoadingViewModel(isLoading: false))
    }
}
