//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Sam on 14/09/2023.
//

import Foundation

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public final class FeedPresenter {
    private let feedLoading: ResourceLoadingView
    private let feedView: FeedView
    private let feedErrorView: ResourceErrorView
    
    public init(feedLoading: ResourceLoadingView, feedView: FeedView, feedErrorView: ResourceErrorView) {
        self.feedLoading = feedLoading
        self.feedView = feedView
        self.feedErrorView = feedErrorView
    }
    
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Title for the feed view")
    }
    
    public static var feedLoadError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR",tableName: "Shared", bundle: Bundle(for: FeedPresenter.self), comment: "Error message display when we can't get the feed from server")
    }
    
    public func didStartLoading() {
        feedErrorView.display(.noError)
        feedLoading.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didFinishSuccess(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        feedLoading.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    public func didFinishFailure(with error: Error) {
        feedErrorView.display(.error(message: Self.feedLoadError))
        feedLoading.display(ResourceLoadingViewModel(isLoading: false))
    }
}
