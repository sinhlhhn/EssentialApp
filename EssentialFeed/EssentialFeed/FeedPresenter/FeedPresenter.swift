//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Sam on 14/09/2023.
//

import Foundation

public final class FeedPresenter {
    
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Title for the feed view")
    }
    
    public static var feedLoadError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR",tableName: "Shared", bundle: Bundle(for: FeedPresenter.self), comment: "Error message display when we can't get the feed from server")
    }
    
    public static func map(_ feed: [FeedImage]) -> FeedViewModel {
        FeedViewModel(feed: feed)
    }
}
