//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Sam on 21/09/2023.
//

import XCTest
import EssentialFeed
import EssentialApp

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase, FeedImageDataLoaderTestCase {
    func test_init_doesNotLoadImageData() {
        let (_, primaryLoader, fallbackLoader) = makeSUT()
        
        XCTAssertEqual(primaryLoader.requestedURLs.isEmpty, true)
        XCTAssertEqual(fallbackLoader.requestedURLs.isEmpty, true)
    }
    
    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(primaryLoader.requestedURLs, [url])
        XCTAssertEqual(fallbackLoader.requestedURLs.isEmpty, true)
    }
    
    func test_loadImageData_loadsFromFallbackLoaderOnPrimaryLoaderFailure() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        _ = sut.loadImageData(from: url) { result in }
        
        primaryLoader.complete(with: anyNSError())
        
        XCTAssertEqual(primaryLoader.requestedURLs, [url])
        XCTAssertEqual(fallbackLoader.requestedURLs, [url])
    }
    
    func test_loadImageData_cancelsPrimaryLoaderTaskOnCancel() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        let task = sut.loadImageData(from: url) { result in }
        
        task.cancel()
        
        XCTAssertEqual(primaryLoader.canceledURLs, [url])
        XCTAssertEqual(fallbackLoader.canceledURLs.isEmpty, true)
    }
    
    func test_loadImageData_cancelsFallbackLoaderTaskOnCancelAfterPrimaryLoaderFailure() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        let task = sut.loadImageData(from: url) { result in }
        
        primaryLoader.complete(with: anyNSError())
        task.cancel()
        
        XCTAssertEqual(primaryLoader.canceledURLs.isEmpty, true)
        XCTAssertEqual(fallbackLoader.canceledURLs, [url])
    }
    
    func test_loadImageData_deliversPrimaryDataOnPrimaryLoaderSuccess() {
        let url = anyURL()
        let expectedData = anyData()
        let (sut, primaryLoader, _) = makeSUT()
        
        expect(sut, completeWithResult: .success(expectedData), from: url) {
            primaryLoader.complete(with: expectedData)
        }
    }
    
    func test_loadImageData_deliversFallbackDataOnFallbackLoaderSuccess() {
        let url = anyURL()
        let fallbackData = anyData()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        expect(sut, completeWithResult: .success(fallbackData), from: url) {
            primaryLoader.complete(with: anyNSError())
            fallbackLoader.complete(with: fallbackData)
        }
    }
    
    func test_loadImageData_deliversErrorOnBothPrimaryAndFallbackLoaderFailure() {
        let url = anyURL()
        let fallbackError = anyNSError()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        expect(sut, completeWithResult: .failure(fallbackError), from: url) {
            primaryLoader.complete(with: anyNSError())
            fallbackLoader.complete(with: fallbackError)
        }
    }
    
    //MARK: -Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedImageDataLoaderWithFallbackComposite, FeedImageDataLoaderSpy, FeedImageDataLoaderSpy) {
        let primaryLoader = FeedImageDataLoaderSpy()
        let fallbackLoader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(fallbackLoader, file: file, line: line)
        trackForMemoryLeak(primaryLoader, file: file, line: line)
        
        return (sut, primaryLoader, fallbackLoader)
    }
}
