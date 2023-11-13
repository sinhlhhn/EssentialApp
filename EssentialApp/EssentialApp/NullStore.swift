//
//  NullStore.swift
//  EssentialApp
//
//  Created by Sam on 08/11/2023.
//

import Foundation
import EssentialFeed

class NullStore: FeedStore & FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws { }
    
    func retrieve(dataFroURL url: URL) throws -> Data? { return .none }
    
    func deleteCacheFeed() throws { }
    
    func insert(_ feed: [LocalFeedImage], currentDate: Date) throws { }
    
    func retrieve() throws -> CachedFeed? { return .none }
}
