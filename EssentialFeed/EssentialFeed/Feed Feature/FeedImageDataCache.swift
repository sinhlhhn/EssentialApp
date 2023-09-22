//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Sam on 22/09/2023.
//

import Foundation

public protocol FeedImageDataCache {
    typealias SaveResult = Result<Void, Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping ((SaveResult) -> Void))
}
