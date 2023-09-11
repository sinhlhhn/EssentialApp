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
        
        let adapterComposer = FeedLoaderPresentationAdapter(feedLoader: loader)
        let refreshController = FeedRefreshViewController(delegate: adapterComposer)
        
        let feedViewController = FeedViewController(refreshController: refreshController)
        adapterComposer.feedPresenter = FeedPresenter(feedLoading: WeakRefVirtualProxy(refreshController), feedView: FeedViewAdapter(controller: feedViewController, loader: imageLoader))
        
        return feedViewController
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

private class FeedImageWeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ weakRef: T) {
        self.object = weakRef
    }
}

extension FeedImageWeakRefVirtualProxy: FeedImageView where T: FeedImageView {
    typealias Image = T.Image
    
    func display(_ viewModel: FeedImageViewModel<T.Image>) {
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
        controller?.tableModel = viewModel.feed.map { model in
            let presenter = FeedImagePresenter<FeedImageCellController, UIImage>(model: model, imageLoader: loader, imageTransfer: UIImage.init)
            let feedImageController = FeedImageCellController(presenter: presenter)
            presenter.view = feedImageController
            
            return feedImageController
        }
    }
}

private class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    private let feedLoader: FeedLoader
    var feedPresenter: FeedPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        feedPresenter?.didStartLoading()
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(images):
                self?.feedPresenter?.didFinishSuccess(with: images)
            case let .failure(error):
                self?.feedPresenter?.didFinishFailure(with: error)
            }
        }
    }
}
