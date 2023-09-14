//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 14/09/2023.
//

import Foundation
import XCTest

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
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
    private let feedErrorView: FeedErrorView
    
    init(feedLoading: FeedLoadingView, feedErrorView: FeedErrorView) {
        self.feedLoading = feedLoading
        self.feedErrorView = feedErrorView
    }
    
    func didStartLoading() {
        feedErrorView.display(.noError)
        feedLoading.display(FeedLoadingViewModel(isLoading: true))
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
    
    //MARK: -Helpers
    
    private func makeSUT() -> (FeedPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(feedLoading: view, feedErrorView: view)
        
        return (sut, view)
    }
    
    private class ViewSpy: FeedLoadingView, FeedErrorView {
        
        enum Message: Equatable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
        }
        
        private(set) var messages: [Message] = []
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }
    }
}


