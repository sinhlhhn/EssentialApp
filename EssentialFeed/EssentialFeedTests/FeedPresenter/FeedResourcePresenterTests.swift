//
//  FeedResourcePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 03/10/2023.
//

import XCTest
import EssentialFeed

final class FeedResourcePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessage() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    func test_didStartLoading_displaysNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoading()
        
        XCTAssertEqual(view.messages, [.display(errorMessage: .none), .display(isLoading: true)])
    }
    
    func test_didFinishSuccess_displayFeedAndStopLoading() {
        let feed = [uniqueImage()]
        let (sut, view) = makeSUT()
        
        sut.didFinishSuccess(with: feed)
        
        XCTAssertEqual(view.messages, [.display(feed: feed), .display(isLoading: false)])
    }
    
    func test_didFinishFailure_displayLocalizedErrorAndStopLoading() {
        let error = anyNSError()
        let (sut, view) = makeSUT()
        
        sut.didFinishFailure(with: error)
        
        XCTAssertEqual(view.messages, [.display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR")), .display(isLoading: false)])
    }
    
    //MARK: -Helpers
    
    private func makeSUT() -> (FeedResourcePresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedResourcePresenter(feedLoading: view, feedView: view, feedErrorView: view)
        
        return (sut, view)
    }
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
            let table = "Feed"
            let bundle = Bundle(for: FeedResourcePresenter.self)
            let value = bundle.localizedString(forKey: key, value: nil, table: table)
            if value == key {
                XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
            }
            return value
        }
    
    private class ViewSpy: FeedLoadingView, FeedView, FeedErrorView {
        
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(feed: [FeedImage])
        }
        
        private(set) var messages: Set<Message> = []
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedViewModel) {
            messages.insert(.display(feed: viewModel.feed))
        }
    }
}
