//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Sam on 11/08/2023.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private class UnexpectedValuesRepresentation: Error {}
    
    private class URLSessionHTTPClientTask: HTTPClientTask {
        let wrapped: URLSessionTask
        
        init(wrapped: URLSessionTask) {
            self.wrapped = wrapped
        }
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data, response, error in
            completion(Result(catching: {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            }))
        }
        
        task.resume()
        
        return URLSessionHTTPClientTask(wrapped: task)
    }
}
