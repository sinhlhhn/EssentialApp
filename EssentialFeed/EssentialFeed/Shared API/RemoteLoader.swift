//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by Sam on 29/09/2023.
//

import Foundation

public final class RemoteLoader<Resource> {
    private let client: HTTPClient
    private let url: URL
    private let mapper: Mapper
    
    public typealias Result = Swift.Result<Resource, Error>
    public typealias Mapper = (Data, HTTPURLResponse) throws -> Resource
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: HTTPClient, url: URL, mapper: @escaping Mapper) {
        self.client = client
        self.url = url
        self.mapper = mapper
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard let self = self  else { return }
            
            switch result {
            case let .success((data, response)):
                completion(self.map(data, response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    private func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
        do {
            let items = try mapper(data, response)
            return .success(items)
        } catch {
            return .failure(.invalidData)
        }
    }
}

