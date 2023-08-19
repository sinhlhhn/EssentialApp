//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Sam on 18/08/2023.
//

import Foundation
import EssentialFeed

func uniqueImage() -> FeedImage {
    FeedImage(id: UUID(), description: "any des", location: nil, url: URL(string: "https://any-url")!)
}

func uniqueImageFeed() -> (models: [FeedImage], locals: [LocalFeedImage]) {
    let feed = [uniqueImage(), uniqueImage()]
    let locals = feed.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.imageURL) }
    return (feed, locals)
}

extension Date {
    private var feedCacheMaxAgeInDays: Int {
        7
    }
    
    func minusFeedCacheMaxAge() -> Date {
        adding(days: -feedCacheMaxAgeInDays)
    }
    
    private func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
