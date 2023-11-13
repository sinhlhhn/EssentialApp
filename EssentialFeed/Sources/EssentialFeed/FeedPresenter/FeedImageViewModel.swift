//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Sam on 14/09/2023.
//

import Foundation

public struct FeedImageViewModel {
    public let location: String?
    public let description: String?
    
    public var hasLocation: Bool {
        return location != nil
    }

    public var hasDescription: Bool {
        description != nil
    }
}
