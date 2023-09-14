//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 14/09/2023.
//

import Foundation
import XCTest
import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
    private let feedLoading: FeedLoadingView
    private let feedView: FeedView
    private let feedErrorView: FeedErrorView
    
    init(feedLoading: FeedLoadingView, feedView: FeedView, feedErrorView: FeedErrorView) {
        self.feedLoading = feedLoading
        self.feedView = feedView
        self.feedErrorView = feedErrorView
    }
    
    func didStartLoading() {
        feedErrorView.display(.noError)
        feedLoading.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishSuccess(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        feedLoading.display(FeedLoadingViewModel(isLoading: false))
    }
}

final class FeedPresenterTests: XCTestCase {
    func test_init_doesNotSendMessage() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    func test_didStartLoadingFeed_displaysNoErrorMessageAndStartsLoading() {
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
    
    //MARK: -Helpers
    
    private func makeSUT() -> (FeedPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(feedLoading: view, feedView: view, feedErrorView: view)
        
        return (sut, view)
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


