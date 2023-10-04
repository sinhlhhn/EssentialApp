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

class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    private let loader: () -> AnyPublisher<Resource, Error>
    var loadPresenter: LoadResourcePresenter<Resource, View>?
    private var cancellable: Cancellable?
    
    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    func loadResource() {
        loadPresenter?.didStartLoading()
        
        cancellable = loader()
            .dispatchOnMainQueue()
            .sink { [weak self] completion in
            switch completion {
            case .finished: break
            case let .failure(error):
                self?.loadPresenter?.didFinishFailure(with: error)
            }
        } receiveValue: { [weak self] resource in
            self?.loadPresenter?.didFinishSuccess(with: resource)
        }
    }
}

extension LoadResourcePresentationAdapter: FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh() {
        loadResource()
    }
}
