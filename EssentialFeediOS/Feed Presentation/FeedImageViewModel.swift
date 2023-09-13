//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Sam on 11/09/2023.
//

import Foundation

struct FeedImageViewModel<Image> {
    let image: Image?
    let shouldRetry: Bool
    let isLoading: Bool
    let location: String?
    let description: String?
    
    var hasLocation: Bool {
        return location != nil
    }
    
    var hasDescription: Bool {
        description != nil
    }
}
