//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Sam on 17/08/2023.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader {
    public typealias LoadResult = Swift.Result<[FeedImage], Error>
    
    public func load() throws -> [FeedImage] {
        if let result = try store.retrieve(), FeedCachePolicy.validate(result.timestamp, against: currentDate()) {
            return result.feed.toModels()
        }
        return []
    }
}

extension LocalFeedLoader {
    public typealias ValidationResult = Result<Void, Error>
    
    private struct InvalidCache: Error {}
    
    public func validateCache() throws {
        do {
            if let result = try store.retrieve(), !FeedCachePolicy.validate(result.timestamp, against: currentDate()) {
                throw InvalidCache()
            }
        } catch {
            try store.deleteCacheFeed()
        }
    }
}

extension LocalFeedLoader: FeedCache {
    public func save(_ feed: [FeedImage]) throws {
        try store.deleteCacheFeed()
        try store.insert(feed.toLocal(), currentDate: currentDate())
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        self.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.imageURL) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        self.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
