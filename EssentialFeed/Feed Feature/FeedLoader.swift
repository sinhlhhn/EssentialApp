//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by sinhlh on 04/08/2023.
//

import Foundation

public enum LoadFeedResult<Error> {
    case success([FeedItem])
    case failure(Error)
}

extension LoadFeedResult: Equatable where Error: Equatable {}

public protocol FeedLoader {
    associatedtype Error
    func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
