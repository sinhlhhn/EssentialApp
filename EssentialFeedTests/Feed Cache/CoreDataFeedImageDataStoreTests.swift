//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 20/09/2023.
//

import XCTest
import EssentialFeed

extension CoreDataFeedStore: FeedImageDataStore {
    public func retrieve(dataFroURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> ()) {
        completion(.success(.none))
    }
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> ()) {
        completion(.success(()))
    }
}

final class CoreDataFeedImageDataStoreTests: XCTestCase {
    func test_retrieveImage_deliverImageDataNotFoundErrorOnEmptyData() {
        let sut = makeSUT()
        
        expect(sut, completionWithResult: notFound(), for: anyURL())
    }
    
    func test_retrieveImage_deliverImageDataNotFoundErrorOnStoreDataURLDoesNotMatch() {
        let sut = makeSUT()
        let url = URL(string: "https://a-url")!
        let nonMatchURL = URL(string: "https://a-non-match-url")!
        
        insert(data: anyData(), for: url, into: sut)
        
        expect(sut, completionWithResult: notFound(), for: nonMatchURL)
    }
    
    //MARK: -Helpers
    
    private func makeSUT() -> CoreDataFeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(filePath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeak(sut)
        
        return sut
    }
    
    private func notFound() -> FeedImageDataStore.RetrievalResult {
        return .success(.none)
    }
    
    private func localFeedImage(url: URL) -> LocalFeedImage {
        return LocalFeedImage(id: UUID(), description: nil, location: nil, url: url)
    }
    
    private func expect(_ sut: CoreDataFeedStore, completionWithResult expectedResult: FeedImageDataStore.RetrievalResult, for url: URL) {
        
        let exp = expectation(description: "Wait for completion")
        sut.retrieve(dataFroURL: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData)
            default:
                XCTFail("Expected \(expectedResult) got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp] ,timeout: 1)
    }
    
    private func insert(data: Data, for url: URL, into sut: CoreDataFeedStore) {
        let image = localFeedImage(url: url)
        
        let exp = expectation(description: "Wait for completion")
        sut.insert([image], currentDate: Date()) { insertionResult in
            switch insertionResult {
            case .success(()):
                sut.insert(data, for: url) { insertionImageResult in
                    switch insertionImageResult {
                    case .success(()):
                        break
                    default:
                        XCTFail("Expected insert successfully got \(insertionImageResult) instead")
                    }
                }
                exp.fulfill()
            default:
                XCTFail("Expected success got \(insertionResult) instead")
            }
        }
        
        wait(for: [exp], timeout: 1)
    }
}
