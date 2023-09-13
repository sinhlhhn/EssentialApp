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
        
        let adapterComposer = FeedLoaderPresentationAdapter(feedLoader: MainQueueDispatchDecorator(decoratee: loader))
        
        let feedViewController = FeedUIComposer.makeWith(delegate: adapterComposer, title: FeedPresenter.title)
        
        adapterComposer.feedPresenter = FeedPresenter(feedLoading: WeakRefVirtualProxy(feedViewController), feedView: FeedViewAdapter(controller: feedViewController, loader: MainQueueDispatchDecorator(decoratee: imageLoader)))
        
        return feedViewController
    }
}

private extension FeedUIComposer {
    static func makeWith(delegate: FeedRefreshViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let sb = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = sb.instantiateViewController(identifier: "FeedViewController"){ coder in
            FeedViewController(coder: coder, delegate: delegate)
        }
        
        feedViewController.title = title
        
        return feedViewController
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
