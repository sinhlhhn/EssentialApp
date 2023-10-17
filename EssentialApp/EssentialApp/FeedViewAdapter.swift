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
    private weak var controller: ListViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private let selection: (FeedImage) -> Void
    
    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    
    init(controller: ListViewController, loader: @escaping (URL) -> FeedImageDataLoader.Publisher, selection: @escaping (FeedImage) -> Void) {
        self.controller = controller
        self.imageLoader = loader
        self.selection = selection
    }
    
    public func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            
            let adapter = ImageDataPresentationAdapter { [imageLoader] in
                imageLoader(model.imageURL)
            }
            
            let feedImageController = FeedImageCellController(
                viewModel: FeedImagePresenter.map(model),
                delegate: adapter,
                selection: { [selection] in
                    selection(model)
                })
            
            adapter.loadPresenter = LoadResourcePresenter(
                loadingView: WeakRefVirtualProxy(feedImageController),
                resourceView: WeakRefVirtualProxy(feedImageController),
                errorView: WeakRefVirtualProxy(feedImageController),
                mapper: UIImage.tryMake)
            
            return CellController(id: model, feedImageController)
        })
    }
}

extension UIImage {
    private struct InvalidImageData: Error {}
    
    static func tryMake(_ data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw InvalidImageData()
        }
        return image
    }
}

