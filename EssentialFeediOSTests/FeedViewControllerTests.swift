//
//  FeedViewControllerTests.swift
//  FeedViewControllerTests
//
//  Created by Sam on 31/08/2023.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    func test_loadFeedCompletion_triggerCellForRowAtIndexPath() {
        let image0 = makeImage(description: "any description", location: "any location")
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0], at: 0)
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "any description", location: "any location")
        let image1 = makeImage(description: nil, location: "any location")
        let image2 = makeImage(description: "any description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentStateOnError() {
        let image = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image], at: 0)
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeLoadingWithError(at: 1)
        
        assertThat(sut, isRendering: [image])
    }
    
    //MARK: -Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(loader)
        
        return (sut, loader)
    }
    
    private func assertThat(_ sut: FeedViewController, isRendering images: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedFeedImageViews() == images.count else {
            XCTFail("Expected \(images.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead", file: file, line: line)
            return
        }
        
        images.enumerated().forEach {
            assertThat(sut, hasViewConfigFor: $0.element, in: $0.offset, file: file, line: line)
        }
    }
    
    private func assertThat(_ sut: FeedViewController, hasViewConfigFor image: FeedImage, in index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
            return
        }
        
        let shouldLocationBeVisible = image.location != nil
        XCTAssertEqual(cell.isShowLocation, shouldLocationBeVisible, "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index \(index) got \(cell.isShowLocation) instead", file: file, line: line)
        XCTAssertEqual(cell.locationText, image.location, "Expected `locationText` to be \(String(describing: image.location)) for image view at index \(index) got \(String(describing: cell.locationText)) instead", file: file, line: line)
        let shouldDescriptionBeVisible = image.description != nil
        XCTAssertEqual(cell.isShowDescription, shouldDescriptionBeVisible,  "Expected `isShowDescription` to be \(shouldDescriptionBeVisible) for image view at index \(index) got \(cell.isShowDescription) instead", file: file, line: line)
        XCTAssertEqual(cell.descriptionText, image.description, "Expected `descriptionText` to be \(String(describing: image.description)) for image view at index \(index) got \(String(describing: cell.descriptionText)) instead", file: file, line: line)
    }
    
    private func makeImage(description: String?, location: String?) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: URL(string: "http://any-url")!)
    }
    
    private class LoaderSpy: FeedLoader {
        private var completions: [(FeedLoader.Result) -> Void] = []
        
        var loadCallCount: Int {
            completions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeLoading(with images: [FeedImage] = [], at index: Int) {
            completions[index](.success(images))
        }
        
        func completeLoadingWithError(at index: Int) {
            let error = NSError(domain: "", code: 1)
            completions[index](.failure(error))
        }
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { (target as NSObject).perform(Selector($0)) }
        }
    }
}

private extension FeedImageCell {
    var isShowLocation: Bool {
        !locationContainer.isHidden
    }
    
    var locationText: String? {
        locationLabel.text
    }
    
    var isShowDescription: Bool {
        !descriptionLabel.isHidden
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
}

private extension UITableViewController {
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        self.tableView.numberOfRows(inSection: feedImageSection)
    }
    
    private var feedImageSection: Int {
        return 0
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImageSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}
