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
//    func test_emptyFeed() {
//        let sut = makeSUT()
//        sut.display(emptyFeed())
//        
//        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), name: "EMPTY_FEED_light")
//        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), name: "EMPTY_FEED_dark")
//    }
//    
//    func test_feedWithContent() {
//        let sut = makeSUT()
//        sut.display(feedWithContent())
//        
//        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), name: "FEED_WITH_CONTENT_light")
//        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), name: "FEED_WITH_CONTENT_dark")
//    }
//    
//    func test_feedWithError() {
//        let sut = makeSUT()
//        sut.display(.error(message: "There is a\nmulti-line\nerror message"))
//        
//        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), name: "FEED_WITH_ERROR_light")
//        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), name: "FEED_WITH_ERROR_dark")
//    }
//
//    
//    func test_feedWithFailedImageLoading() {
//        let sut = makeSUT()
//        sut.display(feedWithFailedImageLoading())
//        
//        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), name: "FEED_WITH_FAILED_IMAGE_LOADING_light")
//        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), name: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
//    }

    //MARK: -Helpers
    
    private func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let sb = UIStoryboard(name: "Feed", bundle: bundle)
        let sut = sb.instantiateViewController(identifier: "FeedViewController") { coder in
            FeedViewController(coder: coder, delegate: RefreshSpy())
        }
        sut.loadViewIfNeeded()
        sut.tableView.showsVerticalScrollIndicator = false
        sut.tableView.showsHorizontalScrollIndicator = false
        
        return sut
    }
    
    private class RefreshSpy: FeedRefreshViewControllerDelegate {
        func didRequestFeedRefresh() {
            
        }
    }
    
    private func emptyFeed() -> [FeedImageCellController] {
        return []
    }
    
    private func feedWithContent() -> [ImageStub] {
        return [
            ImageStub(description: "A short description", location: "HaNoi\nVietNam", image: UIImage.make(with: .red)),
            ImageStub(description: "A long \ndecription", location: "HoChiMinh, VietNam", image: UIImage.make(with: .green))
        ]
    }
    
    private func feedWithFailedImageLoading() -> [ImageStub] {
        return [
            ImageStub(description: "A short description", location: "HaNoi\nVietNam", image: nil),
            ImageStub(description: "A long \ndecription", location: "HoChiMinh, VietNam", image: nil)
        ]
    }
}

private extension FeedViewController {
    func display(_ stubs: [ImageStub]) {
        let cells = stubs.map { stub in
            let controller = FeedImageCellController(viewModel: stub.viewModel, delegate: stub)
            stub.controller = controller
            return controller
        }
        
        display(cells)
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
