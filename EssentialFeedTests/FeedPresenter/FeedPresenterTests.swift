//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 14/09/2023.
//

import Foundation
import XCTest

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
    private let feedErrorView: FeedErrorView
    
    init(feedErrorView: FeedErrorView) {
        self.feedErrorView = feedErrorView
    }
    
    func didStartLoading() {
        feedErrorView.display(.noError)
    }
}

final class FeedPresenterTests: XCTestCase {
    func test_init_doesNotSendMessage() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    func test_didStartLoading_displayNoErrorMessage() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoading()
        
        XCTAssertEqual(view.messages, [.display(errorMessage: .none)])
    }
    
    //MARK: -Helpers
    
    private func makeSUT() -> (FeedPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(feedErrorView: view)
        
        return (sut, view)
    }
    
    private class ViewSpy: FeedErrorView {
        
        enum Message: Equatable {
            case display(errorMessage: String?)
        }
        
        private(set) var messages: [Message] = []
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
    }
}


