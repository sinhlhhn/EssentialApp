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
    private var currentFeed: [FeedImage: CellController] = [:]

    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    private typealias LoadMorePresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>

    init(currentFeed: [FeedImage: CellController] = [:], controller: ListViewController, loader: @escaping (URL) -> FeedImageDataLoader.Publisher, selection: @escaping (FeedImage) -> Void) {
        self.currentFeed = currentFeed
        self.controller = controller
        self.imageLoader = loader
        self.selection = selection
    }

    public func display(_ viewModel: Paginated<FeedImage>) {
        guard let controller = controller else { return }

        var currentFeed = self.currentFeed
        let feed: [CellController] = viewModel.items.map { model in
            if let controller = currentFeed[model] {
                return controller
            }

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

            let controller = CellController(id: model, feedImageController)
            currentFeed[model] = controller
            return controller
        }

        guard let loadMorePublisher = viewModel.loadMorePublisher else {
            controller.display(feed)
            return
        }

        let loadMoreAdapter = LoadMorePresentationAdapter {
            loadMorePublisher()
        }

        let loadMoreCellController = LoadMoreCellController(callback: loadMoreAdapter.loadResource)

        loadMoreAdapter.loadPresenter = LoadResourcePresenter(
            loadingView: WeakRefVirtualProxy(loadMoreCellController),
            resourceView: FeedViewAdapter(
                currentFeed: currentFeed,
                controller: controller,
                loader: imageLoader,
                selection: selection
            ),
            errorView: WeakRefVirtualProxy(loadMoreCellController))

        let loadMore: [CellController] = [
            CellController(id: UUID(), loadMoreCellController)
        ]

        controller.display(feed, loadMore)
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

