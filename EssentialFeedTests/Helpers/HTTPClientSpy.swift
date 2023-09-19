//
//  HTTPClientSpy.swift
//  EssentialFeedTests
//
//  Created by Sam on 19/09/2023.
//

import Foundation
import EssentialFeed

class HTTPClientSpy: HTTPClient {
    private struct Task: HTTPClientTask {
        var onCancel: (() -> Void)
        
        func cancel() {
            onCancel()
        }
    }
    
    private var messages: [(url: URL, completion: ((HTTPClient.Result) -> Void))] = []
    private(set) var canceledRequests: [URL] = []
    
    var requestedURLs: [URL] {
        messages.map { $0.url }
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        messages.append((url, completion))
        return Task { [weak self] in
            self?.canceledRequests.append(url)
        }
    }
    
    func completion(withStatusCode statusCode: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil)
        messages[index].completion(.success((data, response!)))
    }
    
    func completion(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
}
