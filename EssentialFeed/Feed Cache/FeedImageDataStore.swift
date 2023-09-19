//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Sam on 19/09/2023.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>
    
    func retrieve(dataFroURL url: URL, completion: @escaping (Result) -> ())
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> ())
}
