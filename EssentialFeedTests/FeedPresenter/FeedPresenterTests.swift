//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 14/09/2023.
//

import Foundation
import XCTest

final class FeedPresenter {
    
}

final class FeedPresenterTests: XCTestCase {
    func test_init_doesNotSendMessage() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    //MARK: -Helpers
    
    private func makeSUT() -> (FeedPresenter, ViewSpy) {
        let sut = FeedPresenter()
        let view = ViewSpy()
        
        return (sut, view)
    }
    
    private class ViewSpy {
        private(set) var messages: [Any] = []
    }
}


