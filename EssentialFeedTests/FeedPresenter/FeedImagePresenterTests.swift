//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 14/09/2023.
//

import Foundation
import XCTest
import EssentialFeed

final class FeedImagePresenter {
    
}

final class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendMessage() {
        let (_, view) = makeSUT()
        
        XCTAssertEqual(view.messages, [])
    }
    
    //MARK: -Helpers
    
    private func makeSUT() -> (FeedImagePresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter()
        
        return (sut, view)
    }
    
    private class ViewSpy {
        
        enum Message: Hashable {
            
        }
        
        private(set) var messages: Set<Message> = []
    }
}
