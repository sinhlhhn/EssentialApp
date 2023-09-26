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
    func test_emptyFeed() {
        let sut = makeSUT()
        sut.display(emptyFeed())
        
        record(snapshot: sut.snapshot(), name: "EMPTY_FEED")
    }
    
    func test_feedWithContent() {
        let sut = makeSUT()
        sut.display(feedWithContent())
        
        record(snapshot: sut.snapshot(), name: "FEED_WITH_CONTENT")
    }

    //MARK: -Helpers
    
    private func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let sb = UIStoryboard(name: "Feed", bundle: bundle)
        let sut = sb.instantiateViewController(identifier: "FeedViewController") { coder in
            FeedViewController(coder: coder, delegate: RefreshSpy())
        }
        sut.loadViewIfNeeded()
        
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
            ImageStub(viewModel: FeedImageViewModel<UIImage>(image: UIImage.make(with: .red), shouldRetry: false, isLoading: false, location: "HaNoi\nVietNam", description: "A short description")),
            ImageStub(viewModel: FeedImageViewModel<UIImage>(image: UIImage.make(with: .green), shouldRetry: false, isLoading: false, location: "HoChiMinh, VietNam", description: "A long \ndecription"))
        ]
    }
    
    private func record(snapshot: UIImage, name: String, file: StaticString = #filePath, line: UInt = #line) {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate png data representation from snapshot", file: file, line: line)
            return
        }
        
        let snapshotURL = URL(filePath: String(describing: file))
            .deletingLastPathComponent()
            .appending(path: "snapshot")
            .appending(path: "\(name).png")
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL
                    .deletingLastPathComponent(),
                withIntermediateDirectories: true)
            
            try snapshotData.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error \(error)", file: file, line: line)
        }
        
    }
    
}

private extension FeedViewController {
    func display(_ stubs: [ImageStub]) {
        let cells = stubs.map { stub in
            let controller = FeedImageCellController(delegate: stub)
            stub.controller = controller
            return controller
        }
        
        display(cells)
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    let viewModel: FeedImageViewModel<UIImage>
    weak var controller: FeedImageCellController?
    
    init(viewModel: FeedImageViewModel<UIImage>, controller: FeedImageCellController? = nil) {
        self.viewModel = viewModel
        self.controller = controller
    }
    
    func didCancelImageRequest() {
        
    }
    
    func didRequestImage() {
        controller?.display(viewModel)
    }
}

private extension UIViewController {
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { action in
            view.layer.render(in: action.cgContext)
        }
    }
}
