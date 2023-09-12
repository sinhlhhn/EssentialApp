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

final class FeedPresenter {
    private let feedLoading: FeedLoadingView
    private let feedView: FeedView
    
    static var title: String {
        "My Feed"
    }
    
    init(feedLoading: FeedLoadingView, feedView: FeedView) {
        self.feedLoading = feedLoading
        self.feedView = feedView
    }
    
    func didStartLoading() {
        feedLoading.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishSuccess(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        feedLoading.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishFailure(with error: Error) {
        feedLoading.display(FeedLoadingViewModel(isLoading: false))
    }
}
