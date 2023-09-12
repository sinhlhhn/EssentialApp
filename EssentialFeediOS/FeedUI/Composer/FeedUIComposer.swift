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
        
        let bundle = Bundle(for: FeedViewController.self)
        let sb = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = sb.instantiateViewController(identifier: "FeedViewController") as! FeedViewController
        
        let refreshController = feedViewController.refreshController!
        refreshController.delegate = adapterComposer
        
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

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView {
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
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: loader)
            
            let feedImageController = FeedImageCellController(delegate: adapter)
            
            adapter.presenter = FeedImagePresenter(view: WeakRefVirtualProxy(feedImageController), imageTransfer: UIImage.init)
            
            return feedImageController
        }
    }
}

private class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader?
    private var task: FeedImageDataLoaderTask?
    var presenter: FeedImagePresenter<View, Image>?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader?, task: FeedImageDataLoaderTask? = nil) {
        self.model = model
        self.imageLoader = imageLoader
        self.task = task
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        task = imageLoader?.loadImageData(from: model.imageURL) { [weak self] result in
            self?.handle(result)
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
        task = nil
    }
    
    func handle(_ result: Result<Data, Error>) {
        switch result {
        case let .success(data):
            presenter?.didFinishLoadingImageData(with: data, for: model)
        case let .failure(error):
            presenter?.didFinishLoadingImageData(with: error, for: model)
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
