//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by sinhlh on 04/08/2023.
//

import Foundation

enum LoadFeedResult {
    case success(FeedItem)
    case error(Error)
}

protocol FeedLoader {
    func loadFeed(completion: @escaping (LoadFeedResult) -> Void)
}
