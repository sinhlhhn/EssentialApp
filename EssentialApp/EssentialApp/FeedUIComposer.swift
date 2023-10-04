//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Sam on 08/09/2023.
//

import Foundation
import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(loader: @escaping () -> AnyPublisher<[FeedImage], Error>, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> FeedViewController {
        
        let adapterComposer = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(
            loader: loader)
        
        let feedViewController = FeedUIComposer.makeWith(delegate: adapterComposer, title: FeedPresenter.title)
        
        adapterComposer.loadPresenter = LoadResourcePresenter(
            loadingView: WeakRefVirtualProxy(feedViewController),
            resourceView:
                FeedViewAdapter(
                    controller: feedViewController,
                    loader: imageLoader),
            errorView: WeakRefVirtualProxy(feedViewController),
            mapper: FeedPresenter.map)
        
        return feedViewController
    }
    
    private static func makeWith(delegate: FeedRefreshViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let sb = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = sb.instantiateViewController(identifier: "FeedViewController"){ coder in
            FeedViewController(coder: coder, delegate: delegate)
        }
        
        feedViewController.title = title
        
        return feedViewController
    }
}
