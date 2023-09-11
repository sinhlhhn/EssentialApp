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
    var feedLoading: FeedLoadingView?
    var feedView: FeedView?
    
    func didStartLoading() {
        feedLoading?.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishSuccess(with feed: [FeedImage]) {
        feedView?.display(FeedViewModel(feed: feed))
        feedLoading?.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishFailure(with error: Error) {
        feedLoading?.display(FeedLoadingViewModel(isLoading: false))
    }
}
