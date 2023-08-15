//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 15/08/2023.
//

import XCTest

final class LocalFeedLoader {
    
}

final class FeedStore {
    var deleteCachedFeedCallCount = 0
}

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader()
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
}
