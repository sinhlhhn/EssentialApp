//
//  InMemoryFeedStore.swift
//  EssentialAppTests
//
//  Created by Sam on 25/09/2023.
//

import Foundation
import EssentialFeed

class InMemoryFeedStore: FeedStore & FeedImageDataStore {
    private(set) var feedCache: CachedFeed?
    private var feedImageDataCache: [URL: Data] = [:]
    
    init(feedCache: CachedFeed? = nil) {
        self.feedCache = feedCache
    }
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        feedCache = nil
        completion(.success(()))
    }
    
    func insert(_ feed: [EssentialFeed.LocalFeedImage], currentDate: Date, completion: @escaping InsertionCompletion) {
        feedCache = (feed, currentDate)
        completion(.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(feedCache))
    }
    
    func retrieve(dataFroURL url: URL) throws -> Data? {
        let data = feedImageDataCache[url]
        return data
    }
    
    func insert(_ data: Data, for url: URL) throws {
        feedImageDataCache[url] = data
    }
    
    static var empty: InMemoryFeedStore {
        InMemoryFeedStore()
    }
    
    static var withExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date.distantPast))
    }
    
    static var withNonExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date.init()))
    }
}
