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

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = FeedLoader.Result
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(.some((localImages, timestamp))) where FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                completion(.success(localImages.toModels()))
            case .success:
                completion(.success([]))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

extension LocalFeedLoader {
    public typealias ValidationResult = Result<Void, Error>
    
    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCacheFeed(completion: completion)
            case let .success(.some((_, timestamp))) where !FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                self.store.deleteCacheFeed(completion: completion)
            case .success:
                completion(.success(()))
            }
        }
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Result<Void,Error>
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCacheFeed { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.insert(feed: feed, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func insert(feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal(), currentDate: currentDate(), completion: { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success:
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        })
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