//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Sam on 10/08/2023.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    private class UnexpectedValuesRepresentation: Error {}
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTest: XCTestCase {
    
    override func setUp() {
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performGETRequestWithURL() {
        let url = anyURL()
        
        let exp = expectation(description: "Wait for observe")
        
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in
            
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let error = NSError(domain: "error", code: 0)
        let receivedError = resultErrorFor(data: nil, response: nil, error: error) as? NSError
        XCTAssertEqual(error.code, receivedError?.code, "got \(receivedError?.localizedDescription ?? "")")
        XCTAssertEqual(error.domain, receivedError?.domain)
    }
    
    func test_getFromURL_failsOnAllNilValues() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                          line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath,
                                line: UInt = #line) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        var captureError = error
        let exp = expectation(description: "Wait for completion")
        
        sut.get(from: anyURL()) { result in
            switch result {
            case let .failure(receivedError):
                captureError = receivedError
            default:
                XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        
        return captureError
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-url")!
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserve: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequest(observer: @escaping (URLRequest) -> Void) {
            requestObserve = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocolStub.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocolStub.unregisterClass(URLProtocolStub.self)
//            stub = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserve?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
    }
}


//            if let data = URLProtocolStub.stub?.data {
//                client?.urlProtocol(self, didLoad: data)
//            }
//
//            if let response = URLProtocolStub.stub?.response {
//                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
//            }
//
