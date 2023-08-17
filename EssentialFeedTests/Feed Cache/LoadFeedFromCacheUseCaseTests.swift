//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 17/08/2023.
//

import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessage, [])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
    }
    
    final class FeedStoreSpy: FeedStore {
        var deleteCompletion: [DeletionCompletion] = []
        var insertionCompletion: [InsertionCompletion] = []
        
        enum ReceivedMessage: Equatable {
            case deleteCacheFeed
            case insert([LocalFeedImage], Date)
        }
        
        private (set) var receivedMessage = [ReceivedMessage]()
        
        func deleteCacheFeed(completion: @escaping DeletionCompletion) {
            receivedMessage.append(.deleteCacheFeed)
            deleteCompletion.append(completion)
        }
        
        func completeDeletion(with error: Error, at index: Int = 0) {
            deleteCompletion[index](error)
        }
        
        func completeSuccessDeletion(at index: Int = 0) {
            deleteCompletion[index](nil)
        }
        
        func insert(_ feed: [LocalFeedImage], currentDate: Date, completion: @escaping InsertionCompletion) {
            insertionCompletion.append(completion)
            receivedMessage.append(.insert(feed, currentDate))
        }
        
        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletion[index](error)
        }
        
        func completeSuccessInsertion(at index: Int = 0) {
            insertionCompletion[index](nil)
        }
    }
}
