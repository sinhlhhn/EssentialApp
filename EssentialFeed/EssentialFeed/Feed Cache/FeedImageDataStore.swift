//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Sam on 19/09/2023.
//

import Foundation

public protocol FeedImageDataStore: Sendable {
    func retrieve(dataFroURL url: URL) throws -> Data?
    func insert(_ data: Data, for url: URL) throws
}
