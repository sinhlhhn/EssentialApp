//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Sam on 22/09/2023.
//

import Foundation
import EssentialFeed

public final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> ()) -> FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            completion(result.map { data in
                self?.cache.saveIgnoreResult(with: data, from: url)
                return data
            })
        }
    }
}

private extension FeedImageDataCache {
    func saveIgnoreResult(with data: Data, from url: URL) {
        save(data, for: url) { _ in }
    }
}
