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
        let _ = FeedPresenter()
        let view = ViewSpy()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    private class ViewSpy {
        private(set) var messages: [Any] = []
    }
}


