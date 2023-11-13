//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Sam on 17/08/2023.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    
    func deleteCacheFeed() throws
    
    func insert(_ feed: [LocalFeedImage], currentDate: Date) throws
    
    func retrieve() throws -> CachedFeed?
}
