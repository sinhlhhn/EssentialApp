//
//  FeedImageDataMapper.swift
//  EssentialFeed
//
//  Created by Sam on 01/10/2023.
//

import Foundation

public struct FeedImageDataMapper {
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> Data {
        if !response.isOK || data.isEmpty {
            throw Error.invalidData
        }
        return data
    }
    
}
