//
//  FeedResourcePresenter.swift
//  EssentialFeed
//
//  Created by Sam on 03/10/2023.
//

import Foundation

public protocol ResourceView {
    associatedtype ResourceViewModel
    func display(_ viewModel: ResourceViewModel)
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
    public typealias Mapper = (Resource) -> View.ResourceViewModel
    
    private let feedLoading: FeedLoadingView
    private let resourceView: View
    private let feedErrorView: FeedErrorView
    private let mapper: Mapper
    
    public init(feedLoading: FeedLoadingView, resourceView: View, feedErrorView: FeedErrorView, mapper: @escaping Mapper) {
        self.feedLoading = feedLoading
        self.resourceView = resourceView
        self.feedErrorView = feedErrorView
        self.mapper = mapper
    }
    
    private var feedLoadError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR",tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Error message display when we can't get the feed from server")
    }
    
    public func didStartLoading() {
        feedErrorView.display(.noError)
        feedLoading.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishSuccess(with resource: Resource) {
        resourceView.display(mapper(resource))
        feedLoading.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishFailure(with error: Error) {
        feedErrorView.display(.error(message: feedLoadError))
        feedLoading.display(FeedLoadingViewModel(isLoading: false))
    }
}
