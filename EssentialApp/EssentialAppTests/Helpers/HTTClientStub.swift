//
//  HTTClientStub.swift
//  EssentialAppTests
//
//  Created by Sam on 25/09/2023.
//

import Foundation
import EssentialFeed

class HTTPClientStub: HTTPClient {
    private class Task: HTTPClientTask {
        func cancel() { }
    }
    
    private let stub: (URL) -> HTTPClient.Result
    
    init(stub: @escaping (URL) -> HTTPClient.Result) {
        self.stub = stub
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> EssentialFeed.HTTPClientTask {
        completion(stub(url))
        return Task()
    }
    
    static var offline: HTTPClientStub {
        return HTTPClientStub { _ in
                .failure(NSError(domain: "offline", code: 0))
        }
    }
    
    static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
        return HTTPClientStub { url in
                .success(stub(url))
        }
    }
}
