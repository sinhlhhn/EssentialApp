//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by sinhlh on 04/08/2023.
//

import Foundation

protocol FeedLoader {
    func loadFeed(completion: @escaping (Result<FeedItem, Error>) -> Void)
}
