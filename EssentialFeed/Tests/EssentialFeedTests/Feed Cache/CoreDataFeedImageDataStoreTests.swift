//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 20/09/2023.
//

import XCTest
import EssentialFeed
import TestHelpers

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
    
    func test_retrieveImage_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL() {
        let sut = makeSUT()
        let data = anyData()
        let url = anyURL()
        
        insert(data: data, for: url, into: sut)
        
        expect(sut, completionWithResult: found(data), for: url)
    }
    
    func test_retrieveImage_deliversLastInsertedValue() {
        let sut = makeSUT()
        let firstData = anyData()
        let lastData = anyData()
        let url = anyURL()
        
        insert(data: firstData, for: url, into: sut)
        insert(data: lastData, for: url, into: sut)
        
        expect(sut, completionWithResult: found(lastData), for: url)
    }
    
    //MARK: -Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataFeedStore {
        let storeURL = URL(filePath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL)
        trackForMemoryLeak(sut, file: file, line: line)
        
        return sut
    }
    
    private func notFound() -> Result<Data?, Error> {
        return .success(.none)
    }
    
    private func localFeedImage(url: URL) -> LocalFeedImage {
        return LocalFeedImage(id: UUID(), description: nil, location: nil, url: url)
    }
    
    private func found(_ data: Data) -> Result<Data?, Error> {
        return .success(data)
    }
    
    private func expect(_ sut: CoreDataFeedStore, completionWithResult expectedResult: Result<Data?, Error>, for url: URL, file: StaticString = #filePath, line: UInt = #line) {
        
        let receivedResult = Result { try sut.retrieve(dataFroURL: url) }
        
        switch (receivedResult, expectedResult) {
        case let (.success(receivedData), .success(expectedData)):
            XCTAssertEqual(receivedData, expectedData, file: file, line: line)
        default:
            XCTFail("Expected \(expectedResult) got \(receivedResult) instead", file: file, line: line)
        }
    }
    
    private func insert(data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let image = localFeedImage(url: url)
        
        
        let insertionResult = Result { try sut.insert([image], currentDate: Date()) }
        switch insertionResult {
        case .success(()): break
        default:
            XCTFail("Expected insert successfully got \(insertionResult) instead", file: file, line: line)
        }
        
        do {
            try sut.insert(data, for: url)
        } catch {
            XCTFail("Failed to insert \(data) with \(error)", file: file, line: line)
        }
    }
}
