//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by sinhlh on 04/08/2023.
//

import Foundation

typealias FeedItemResult = Result<FeedItem, Error>

protocol FeedLoader {
    func loadFeed(completion: @escaping (FeedItemResult) -> Void)
}
