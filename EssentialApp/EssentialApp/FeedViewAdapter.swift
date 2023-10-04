//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Sam on 13/09/2023.
//

import Foundation
import UIKit
import EssentialFeed
import EssentialFeediOS

public class FeedViewAdapter: ResourceView {
    private weak var controller: FeedViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    
    init(controller: FeedViewController, loader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = loader
    }
    
    public func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            
            let adapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>> { [imageLoader] in
                imageLoader(model.imageURL)
            }
            
            let feedImageController = FeedImageCellController(
                viewModel: FeedImagePresenter.map(model),
                delegate: adapter)
            
            adapter.loadPresenter = LoadResourcePresenter(
                loadingView: WeakRefVirtualProxy(feedImageController),
                resourceView: WeakRefVirtualProxy(feedImageController),
                errorView: WeakRefVirtualProxy(feedImageController),
                mapper: { data in
                    guard let image = UIImage(data: data) else {
                        throw InvalidImageData()
                    }
                    return image
                })
            
            return feedImageController
        })
    }
}

private struct InvalidImageData: Error {}
