//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Sam on 22/09/2023.
//

import Foundation

public protocol FeedCache {
    func save(_ feed: [FeedImage]) throws
}
