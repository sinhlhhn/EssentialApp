//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Sam on 16/10/2023.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
import EssentialApp

class CommentsUIIntegrationTests: FeedUIIntegrationTests {
    
    override func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, feedTitle)
    }
    
    override func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadFeedCallCount, 0)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3)
    }
    
    override func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
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
    
    override func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
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
    
    override func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterLoadedNonEmptyFeed() {
        let image0 = makeImage()
        let image1 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0, image1], at: 0)
        assertThat(sut, isRendering: [image0, image1])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }
    
    override func test_loadFeedCompletion_doesNotAlterCurrentStateOnError() {
        let image = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image], at: 0)
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeLoadingWithError(at: 1)
        
        assertThat(sut, isRendering: [image])
    }
    
    override func test_loadFeedCompletion_dispatchFromBackgroundThreadToMainThread() {
        let image = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "wait for completion")
        DispatchQueue.global().async {
            loader.completeLoading(with: [image], at: 0)
            exp.fulfill()
        }
        
        
        wait(for: [exp], timeout: 1)
    }
    
    override func test_errorView_doesNotRenderErrorOnLoadFeed() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    override func test_errorView_rendersErrorOnLoadError() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoadingWithError(at: 0)
        
        XCTAssertEqual(sut.errorMessage, loadError)
    }
    
    override func test_errorView_hideErrorOnReload() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoadingWithError(at: 0)
        sut.simulateUserInitiatedFeedReload()
        
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    override func test_errorView_hideErrorOnTapError() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoadingWithError(at: 0)
        sut.simulateTapErrorMessage()
        
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    //MARK: -Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (ListViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(loader: loader.loadPublisher, imageLoader: loader.loadImageDataPublisher)
        
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(loader, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url")!) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }
}
