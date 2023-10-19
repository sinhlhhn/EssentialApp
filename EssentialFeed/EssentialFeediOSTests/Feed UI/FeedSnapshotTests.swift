//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Sam on 25/09/2023.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class FeedSnapshotTests: XCTestCase {
    
    func test_feedWithContent() {
        let sut = makeSUT()
        sut.display(feedWithContent())
        
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .light)), name: "FEED_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .dark)), name: "FEED_WITH_CONTENT_dark")
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .light, contentSize: .extraExtraExtraLarge)), name: "FEED_WITH_CONTENT_light_extraExtraExtraLarge")
    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()
        sut.display(feedWithFailedImageLoading())
        
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .light)), name: "FEED_WITH_FAILED_IMAGE_LOADING_light")
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .dark)), name: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .light, contentSize: .extraExtraExtraLarge)), name: "FEED_WITH_FAILED_IMAGE_LOADING_light_extraExtraExtraLarge")
    }
    
    func test_feedWithLoadMoreIndicator() {
        let sut = makeSUT()
        sut.display(feedWithLoadMoreIndicator())
        
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .light)), name: "FEED_WITH_LOAD_MORE_INDICATOR_light")
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .dark)), name: "FEED_WITH_LOAD_MORE_INDICATOR_dark")
    }
    
    func test_feedWithLoadMoreMessage() {
        let sut = makeSUT()
        sut.display(feedWithLoadMoreMessage())
        
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .light)), name: "FEED_WITH_LOAD_MORE_ERROR_light")
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .dark)), name: "FEED_WITH_LOAD_MORE_ERROR_dark")
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .light, contentSize: .extraExtraExtraLarge)), name: "FEED_WITH_LOAD_MORE_ERROR_light_extraExtraExtraLarge")
    }

    //MARK: -Helpers
    
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let sb = UIStoryboard(name: "Feed", bundle: bundle)
        let sut = sb.instantiateViewController(identifier: "FeedViewController") as! ListViewController
        sut.loadViewIfNeeded()
        sut.tableView.showsVerticalScrollIndicator = false
        sut.tableView.showsHorizontalScrollIndicator = false
        
        return sut
    }
    
    private func feedWithContent() -> [ImageStub] {
        return [
            ImageStub(description: "A short description", location: "HaNoi\nVietNam", image: UIImage.make(with: .red)),
            ImageStub(description: "A long \ndecription", location: "HoChiMinh, VietNam", image: UIImage.make(with: .green))
        ]
    }
    
    private func feedWithLoadMoreIndicator() -> [CellController] {
        let loadMoreCell = LoadMoreCellController()
        loadMoreCell.display(ResourceLoadingViewModel(isLoading: true))
        
        return feedWith(loadMore: loadMoreCell)
    }
    
    private func feedWithLoadMoreMessage() -> [CellController] {
        let loadMoreCell = LoadMoreCellController()
        loadMoreCell.display(ResourceErrorViewModel(message: "a message"))
        
        return feedWith(loadMore: loadMoreCell)
    }
    
    private func feedWith(loadMore: LoadMoreCellController) -> [CellController] {
        let stub = ImageStub(description: "A short description", location: "HaNoi\nVietNam", image: UIImage.make(with: .red))
        let controller = FeedImageCellController(viewModel: stub.viewModel, delegate: stub, selection: {})
        stub.controller = controller
        
        return [
            CellController(id: UUID(), controller),
            CellController(id: UUID(), loadMore)
        ]
    }
    
    private func feedWithFailedImageLoading() -> [ImageStub] {
        return [
            ImageStub(description: "A short description", location: "HaNoi\nVietNam", image: nil),
            ImageStub(description: "A long \ndecription", location: "HoChiMinh, VietNam", image: nil)
        ]
    }
}

private extension ListViewController {
    func display(_ stubs: [ImageStub]) {
        let cells = stubs.map { stub in
            let controller = FeedImageCellController(viewModel: stub.viewModel, delegate: stub, selection: {})
            stub.controller = controller
            return controller
        }
        
        display(cells.map { CellController(id: UUID(),$0) })
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    private let image: UIImage?
    let viewModel: FeedImageViewModel
    weak var controller: FeedImageCellController?
    
    init(description: String?, location: String?, image: UIImage?) {
        self.viewModel = FeedImageViewModel(location: location, description: description)
        self.image = image
    }
    
    func didCancelImageRequest() {
        
    }
    
    func didRequestImage() {
        controller?.display(ResourceLoadingViewModel(isLoading: false))
        
        if let image = image {
            controller?.display(image)
            controller?.display(ResourceErrorViewModel(message: .none))
        } else {
            controller?.display(ResourceErrorViewModel(message: "any"))
        }
    }
}
