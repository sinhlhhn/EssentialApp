//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by Sam on 16/10/2023.
//

import Foundation
import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class CommentsUIComposer {
    private init() {}
    
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>
    
    public static func commentsComposedWith(loader: @escaping () -> AnyPublisher<[FeedImage], Error>, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> ListViewController {
        
        let adapterComposer = FeedPresentationAdapter(
            loader: loader)
        
        let feedViewController = CommentsUIComposer.makeWith(title: FeedPresenter.title, onRefresh: adapterComposer.loadResource)
        feedViewController.onRefresh = adapterComposer.loadResource
        
        
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
    
    private static func makeWith(title: String, onRefresh: (() -> ())?) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let sb = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = sb.instantiateViewController(identifier: "FeedViewController") as! ListViewController
        
        feedViewController.title = title
        
        return feedViewController
    }
}
