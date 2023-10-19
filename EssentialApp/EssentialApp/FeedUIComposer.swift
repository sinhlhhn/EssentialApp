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
    
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
    
    public static func feedComposedWith(
        loader: @escaping () -> AnyPublisher<Paginated<FeedImage>, Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
        selection: @escaping (FeedImage) -> Void = { _ in }
    ) -> ListViewController {
        
        let adapterComposer = FeedPresentationAdapter(
            loader: loader)
        
        let feedViewController = FeedUIComposer.makeWith(title: FeedPresenter.title, onRefresh: adapterComposer.loadResource)
        feedViewController.onRefresh = adapterComposer.loadResource
        
        
        adapterComposer.loadPresenter = LoadResourcePresenter(
            loadingView: WeakRefVirtualProxy(feedViewController),
            resourceView:
                FeedViewAdapter(
                    controller: feedViewController,
                    loader: imageLoader,
                    selection: selection),
            errorView: WeakRefVirtualProxy(feedViewController))
        
        return feedViewController
    }
    
    private static func makeWith(title: String, onRefresh: (() -> ())?) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let sb = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = sb.instantiateViewController(identifier: "FeedViewController") as! ListViewController
        
        feedViewController.title = title
        
        return feedViewController
    }
}
