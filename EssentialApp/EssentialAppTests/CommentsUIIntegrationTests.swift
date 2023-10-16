//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Sam on 16/10/2023.
//

import XCTest
import Combine
import EssentialFeed
import EssentialFeediOS
import EssentialApp

class CommentsUIIntegrationTests: XCTestCase {
    
    func test_commentsView_hasTitle() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, commentsTitle)
    }
    
    func test_loadCommentsActions_requestCommentsFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCommentsCallCount, 0)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCommentsCallCount, 1)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3)
    }
    
    func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
        let comment0 = makeComment(message: "a message", username: "a username")
        let comment1 = makeComment(message: "another message", username: "another username")
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [ImageComment]())
        
        loader.completeLoading(with: [comment0], at: 0)
        assertThat(sut, isRendering: [comment0])
        
        sut.simulateUserInitiatedReload()
        loader.completeLoading(with: [comment0, comment1], at: 1)
        assertThat(sut, isRendering: [comment0, comment1])
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterLoadedNonEmptyFeed() {
        let comment0 = makeComment()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [comment0], at: 0)
        assertThat(sut, isRendering: [comment0])
        
        sut.simulateUserInitiatedReload()
        loader.completeLoading(with: [], at: 1)
        assertThat(sut, isRendering: [ImageComment]())
    }
    
    func test_loadCommentsCompletion_doesNotAlterCurrentStateOnError() {
        let comment = makeComment(message: "a message", username: "a username")
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [comment], at: 0)
        
        sut.simulateUserInitiatedReload()
        loader.completeLoadingWithError(at: 1)
        
        assertThat(sut, isRendering: [comment])
    }
    
    func test_loadCommentsCompletion_dispatchFromBackgroundThreadToMainThread() {
        let image = makeComment()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "wait for completion")
        DispatchQueue.global().async {
            loader.completeLoading(with: [image], at: 0)
            exp.fulfill()
        }
        
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_errorView_doesNotRenderErrorOnLoadFeed() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_errorView_rendersErrorOnLoadError() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoadingWithError(at: 0)
        
        XCTAssertEqual(sut.errorMessage, loadError)
    }
    
    func test_errorView_hideErrorOnReload() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoadingWithError(at: 0)
        sut.simulateUserInitiatedReload()
        
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_errorView_hideErrorOnTapError() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoadingWithError(at: 0)
        sut.simulateTapErrorMessage()
        
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    //MARK: -Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (ListViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(loader: loader.loadPublisher)
        
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(loader, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func makeComment(message: String = "any message", username: String = "any username") -> ImageComment {
        ImageComment(id: UUID(), message: message, createdAt: Date(), username: username)
    }
    
    func assertThat(_ sut: ListViewController, isRendering comments: [ImageComment], file: StaticString = #filePath, line: UInt = #line) {
        
        guard sut.numberOfRenderedCommentsViews() == comments.count else {
            XCTFail("Expected \(comments.count) images, got \(sut.numberOfRenderedCommentsViews()) instead", file: file, line: line)
            return
        }
        
        let viewModel = ImageCommentsPresenter.map(comments)
        
        viewModel.comments.enumerated().forEach { index, viewModel in
            XCTAssertEqual(sut.commentMessage(at: index), viewModel.message)
            XCTAssertEqual(sut.commentDate(at: index), viewModel.date)
            XCTAssertEqual(sut.commentUsername(at: index), viewModel.username)
        }
    }
    
    private class LoaderSpy {
        
        private var requests: [PassthroughSubject<[ImageComment], Error>] = []
        
        func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
            let publisher = PassthroughSubject<[ImageComment], Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        var loadCommentsCallCount: Int {
            requests.count
        }
        
        func completeLoading(with images: [ImageComment] = [], at index: Int) {
            requests[index].send(images)
        }
        
        func completeLoadingWithError(at index: Int) {
            let error = NSError(domain: "", code: 1)
            requests[index].send(completion: .failure(error))
        }
    }
}
