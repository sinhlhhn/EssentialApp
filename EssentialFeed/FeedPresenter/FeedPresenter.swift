//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Sam on 14/09/2023.
//

import Foundation

public struct FeedLoadingViewModel {
    public let isLoading: Bool
}

public protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

public struct FeedViewModel {
    public let feed: [FeedImage]
}

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public struct FeedErrorViewModel {
    public let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}

public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

public final class FeedPresenter {
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
