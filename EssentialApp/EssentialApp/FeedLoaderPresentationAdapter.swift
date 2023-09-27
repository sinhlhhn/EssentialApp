//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Sam on 13/09/2023.
//

import Foundation
import Combine
import EssentialFeediOS
import EssentialFeed

class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    private let feedLoader: () -> FeedLoader.Publisher
    var feedPresenter: FeedPresenter?
    private var cancellable: Cancellable?
    
    init(feedLoader: @escaping () -> FeedLoader.Publisher) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        feedPresenter?.didStartLoading()
        
        cancellable = feedLoader()
            .dispatchOnMainQueue()
            .sink { [weak self] completion in
            switch completion {
            case .finished: break
            case let .failure(error):
                self?.feedPresenter?.didFinishFailure(with: error)
            }
        } receiveValue: { [weak self] images in
            self?.feedPresenter?.didFinishSuccess(with: images)
        }
    }
}
