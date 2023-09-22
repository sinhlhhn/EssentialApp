//
//  RemoteFeedLoaderItem.swift
//  EssentialFeed
//
//  Created by Sam on 17/08/2023.
//

import Foundation

struct RemoteFeedLoaderItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
