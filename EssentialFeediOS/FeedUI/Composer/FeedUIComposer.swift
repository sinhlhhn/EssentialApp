//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Sam on 08/09/2023.
//

import Foundation
import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(loader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presenter = FeedPresenter()
        let adapterComposer = FeedLoaderPresentationAdapter(feedLoader: loader, feedPresenter: presenter)
        let refreshController = FeedRefreshViewController(delegate: adapterComposer)
        
        let feedViewController = FeedViewController(refreshController: refreshController)
        
        presenter.feedLoading = WeakRefVirtualProxy(refreshController)
        presenter.feedView = FeedViewAdapter(controller: feedViewController, loader: imageLoader)
        
        return feedViewController
    }
    
    private static func adaptFeedToCellController(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> (([FeedImage]) -> ()) {
        return { [weak controller] images in
            controller?.tableModel = images.map { FeedImageCellController(viewModel: FeedImageViewModel(model: $0, imageLoader: loader, imageTransfer: UIImage.init))}
        }
    }
}

private class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ weakRef: T) {
        self.object = weakRef
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

private class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let loader: FeedImageDataLoader
    
    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { FeedImageCellController(viewModel: FeedImageViewModel(model: $0, imageLoader: loader, imageTransfer: UIImage.init))}
    }
}

private class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    private let feedLoader: FeedLoader
    private let feedPresenter: FeedPresenter
    
    init(feedLoader: FeedLoader, feedPresenter: FeedPresenter) {
        self.feedLoader = feedLoader
        self.feedPresenter = feedPresenter
    }
    
    func didRequestFeedRefresh() {
        feedPresenter.didStartLoading()
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(images):
                self?.feedPresenter.didFinishSuccess(with: images)
            case let .failure(error):
                self?.feedPresenter.didFinishFailure(with: error)
            }
        }
    }
}
