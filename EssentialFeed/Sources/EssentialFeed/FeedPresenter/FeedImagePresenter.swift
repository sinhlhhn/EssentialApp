//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Sam on 14/09/2023.
//

import Foundation

public final class FeedImagePresenter {
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            location: image.location,
            description: image.description)
    }
}
