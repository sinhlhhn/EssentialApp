//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Sam on 10/08/2023.
//

import XCTest
import EssentialFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionDataTask
}

protocol HTTPSessionDataTask {
    func resume()
}

class URLSessionHTTPClient {
    let session: HTTPSession
    
    init(session: HTTPSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTest: XCTestCase {
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "https://any-url")!
        let session = HTTPSessionSpy()
        let task = URLSessionTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "https://any-url")!
        let session = HTTPSessionSpy()
        let error = NSError(domain: "error", code: 0)
        session.stub(url: url, error: error)
        
        let sut = URLSessionHTTPClient(session: session)
        
        let exp = expectation(description: "get error async")
        sut.get(from: url) { result in
            switch result {
            case let .failure(receiveError):
                XCTAssertEqual(error, receiveError as NSError)
            default:
                XCTFail("Expected failure with \(error), got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private class HTTPSessionSpy: HTTPSession {
        private var stubs: [URL: Stub] = [:]
        
        private struct Stub {
            let task: HTTPSessionDataTask
            let error: Error?
        }
        
        func stub(url: URL, task: HTTPSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionDataTask {
            guard let task = stubs[url]?.task else {
                fatalError("Couldn't find stub for \(url)")
            }
            completionHandler(nil, nil, stubs[url]?.error)
            return task
        }
        
    }
    
    private class FakeURLSessionDataTask: HTTPSessionDataTask {
        func resume() { }
    }
    
    private class URLSessionTaskSpy: HTTPSessionDataTask {
        var resumeCallCount: Int = 0
        
        func resume() {
            resumeCallCount += 1
        }
    }
}
