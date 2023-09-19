//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Sam on 19/09/2023.
//

import Foundation

public final class RemoteFeedImageDataLoader {
    let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    private class RemoteFeedImageDataLoaderTask: FeedImageDataLoaderTask {
        var completion: ((FeedImageDataLoader.Result) -> ())?
        
        init(completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        var wrapped: HTTPClientTask?
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFutureCompletions()
            wrapped?.cancel()
        }
        
        private func preventFutureCompletions() {
            completion = nil
        }
    }
    
    @discardableResult
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> ()) -> FeedImageDataLoaderTask {
        let task = RemoteFeedImageDataLoaderTask(completion: completion)
        
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .failure(error):
                task.completion?(.failure(error))
            case let .success((data, response)):
                if response.statusCode == 200, !data.isEmpty {
                    task.completion?(.success(data))
                } else {
                    task.completion?(.failure(Error.invalidData))
                }
            }
        }
        
        return task
    }
}
