//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 24/08/2023.
//

import XCTest
import EssentialFeed

final class CoreDataFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        
    }
    
    func test_retrieve_deliversFoundValueOnNonEmptyCache() {
        
    }
    
    func test_retrieve_hasNoSideEffectOnNonEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_insert_overridesPreviouslyInsertedCache() {
        
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_delete_hasNoSideEffectOnEmptyCache() {
        
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_delete_emptiesPreviouslyInsertedCached() {
        
    }
    
    func test_storeSideEffect_runSerially() {
        
    }
    
    func test_retrieve_deliverFailureOnRetrievalError() {
        
    }
    
    func test_retrieve_hasNoSideEffectOnRetrievalError() {
        
    }
    
    func test_insert_deliversFailureOnInsertionError() {
        
    }
    
    func test_insert_hasNoSideEffectOnInsertionError() {
        
    }
    
    func test_delete_deliverErrorOnDeletionError() {
        
    }
    
    func test_delete_hasNoSideEffectOnDeletionError() {
        
    }
    
    //MARK: -Helpers
    
    private func makeSUT() -> FeedStore {
        let sut = CoreDataFeedStore()
        trackForMemoryLeak(sut)
        return sut
    }
}
