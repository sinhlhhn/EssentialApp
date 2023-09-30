//
//  RemoteImageCommentLoader.swift
//  EssentialFeed
//
//  Created by Sam on 29/09/2023.
//

import Foundation

public typealias RemoteImageCommentLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentLoader {
    convenience init(client: HTTPClient, url: URL) {
        self.init(client: client, url: url, mapper: ImageCommentsMapper.map)
    }
}
