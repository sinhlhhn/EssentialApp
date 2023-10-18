//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Sam on 21/09/2023.
//

import Foundation
import EssentialFeed

func anyURL() -> URL {
    return URL(string: "https://any-url")!
}

func anyNSError() -> NSError {
    return NSError(domain: "0", code: 0)
}

func anyData() -> Data {
    return Data("any-data".utf8)
}

func uniqueImage() -> [FeedImage] {
    return [FeedImage(id: UUID(), description: nil, location: nil, url: URL(string: "https://any-url")!)]
}

var loadError: String {
    FeedPresenter.feedLoadError
}

var feedTitle: String {
    FeedPresenter.title
}

var commentsTitle: String {
    ImageCommentsPresenter.title
}
