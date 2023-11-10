//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Sam on 22/09/2023.
//

import Foundation

public protocol FeedImageDataCache {
    func save(_ data: Data, for url: URL) throws
}
