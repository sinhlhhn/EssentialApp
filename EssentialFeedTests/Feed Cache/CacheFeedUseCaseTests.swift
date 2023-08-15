//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 15/08/2023.
//

import XCTest

final class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore = FeedStore()) {
        self.store = store
    }
    
    func save() {
        store.deleteCacheFeed()
    }
}

final class FeedStore {
    var deleteCachedFeedCallCount = 0
    
    func deleteCacheFeed() {
        deleteCachedFeedCallCount += 1
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader()
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestCacheDeletion() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
        sut.save()
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
}
