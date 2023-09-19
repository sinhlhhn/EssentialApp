//
//  URLProtocolStub.swift
//  EssentialFeedTests
//
//  Created by Sam on 19/09/2023.
//

import Foundation

class URLProtocolStub: URLProtocol {
    private static var _stub: Stub?
    private static var stub: Stub? {
        get { return queue.sync {
            _stub
        }}
        set { queue.sync {
            _stub = newValue
        }}
    }
    
    
    private static let queue = DispatchQueue(label: "URLProtocol.stub")
    
    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
        let requestObserve: ((URLRequest) -> Void)?
    }
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stub = Stub(data: data, response: response, error: error, requestObserve: nil)
    }
    
    static func observeRequest(observer: @escaping (URLRequest) -> Void) {
        stub = Stub(data: nil, response: nil, error: nil, requestObserve: observer)
    }
    
    static func removeStub() {
        stub = nil
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let stub = URLProtocolStub.stub else { return }
        
        if let data = URLProtocolStub.stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = URLProtocolStub.stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = URLProtocolStub.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
        
        stub.requestObserve?(request)
    }
    
    override func stopLoading() { }
}
