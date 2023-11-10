//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Sam on 19/09/2023.
//

import Foundation

public protocol FeedImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>
    
    @available(*, deprecated)
    func retrieve(dataFroURL url: URL, completion: @escaping (RetrievalResult) -> ())
    @available(*, deprecated)
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> ())
    
    func retrieve(dataFroURL url: URL) throws -> Data?
    func insert(_ data: Data, for url: URL) throws
}

public extension FeedImageDataStore {
    func retrieve(dataFroURL url: URL) throws -> Data? {
        let group = DispatchGroup()
        group.enter()
        
        var data: Result<Data?, Error>?
        retrieve(dataFroURL: url) { result in
            data = result
            group.leave()
        }
        
        group.wait()
        
        return try data?.get()
    }
    
    func insert(_ data: Data, for url: URL) throws {
        let group = DispatchGroup()
        group.enter()
        
        insert(data, for: url) { result in
            group.leave()
        }
        
        group.wait()
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> ()) {}
}
