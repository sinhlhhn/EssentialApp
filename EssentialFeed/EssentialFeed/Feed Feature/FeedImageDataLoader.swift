//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Sam on 08/09/2023.
//

import Foundation

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}
