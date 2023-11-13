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
    private var isLoading = false
    
    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    func loadResource() {
        guard !isLoading else { return }
        
        loadPresenter?.didStartLoading()
        isLoading = true
        cancellable = loader()
            .dispatchOnMainQueue()
            .handleEvents(receiveCancel: { [weak self] in
                self?.isLoading = false
            })
            .sink { [weak self] completion in
            switch completion {
            case .finished: break
            case let .failure(error):
                self?.loadPresenter?.didFinishLoading(with: error)
            }
                self?.isLoading = false
        } receiveValue: { [weak self] resource in
            self?.loadPresenter?.didFinishLoading(with: resource)
        }
    }
}

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
    func didRequestImage() {
        loadResource()
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
        cancellable = nil
    }
}
