//
//  FeedResourcePresenter.swift
//  EssentialFeed
//
//  Created by Sam on 03/10/2023.
//

import Foundation

public protocol ResourceView {
    func display(_ viewModel: String)
}

public final class FeedResourcePresenter {
    public typealias Mapper = (String) -> String
    
    private let feedLoading: FeedLoadingView
    private let resourceView: ResourceView
    private let feedErrorView: FeedErrorView
    private let mapper: Mapper
    
    public init(feedLoading: FeedLoadingView, resourceView: ResourceView, feedErrorView: FeedErrorView, mapper: @escaping Mapper) {
        self.feedLoading = feedLoading
        self.resourceView = resourceView
        self.feedErrorView = feedErrorView
        self.mapper = mapper
    }
    
    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Error message display when we can't get the feed from server")
    }
    
    public func didStartLoading() {
        feedErrorView.display(.noError)
        feedLoading.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishSuccess(with resource: String) {
        resourceView.display(mapper(resource))
        feedLoading.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishFailure(with error: Error) {
        feedErrorView.display(.error(message: feedLoadError))
        feedLoading.display(FeedLoadingViewModel(isLoading: false))
    }
}
