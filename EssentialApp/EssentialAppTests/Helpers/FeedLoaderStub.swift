//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Sam on 22/09/2023.
//

import Foundation
import EssentialFeed

class FeedLoaderStub: FeedLoader {
    let result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
        self.result = result
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
