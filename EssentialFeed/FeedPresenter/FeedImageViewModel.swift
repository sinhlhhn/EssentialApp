//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Sam on 14/09/2023.
//

import Foundation

public struct FeedImageViewModel<Image> {
    public let image: Image?
    public let shouldRetry: Bool
    public let isLoading: Bool
    public let location: String?
    public let description: String?
}
