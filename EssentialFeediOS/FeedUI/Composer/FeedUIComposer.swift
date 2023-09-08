//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Sam on 08/09/2023.
//

import Foundation
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(loader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let refreshController = FeedRefreshViewController(feedLoader: loader)
        
        let feedViewController = FeedViewController(refreshController: refreshController)
        
        refreshController.onRefresh = { [weak feedViewController] images in
            feedViewController?.tableModel = images.map { FeedImageCellController(model: $0, imageLoader: imageLoader)}
        }
        
        return feedViewController
    }
}
