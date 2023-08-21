//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Sam on 21/08/2023.
//

import Foundation

public final class CodableFeedStore: FeedStore {
    let storeURL: URL
    
    public init(url: URL) {
        self.storeURL = url
    }
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            feed.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Codable {
        let id: UUID
        let description: String?
        let location: String?
        let url: URL
        
        init(_ item: LocalFeedImage) {
            self.id = item.id
            self.description = item.description
            self.location = item.location
            self.url = item.url
        }
        
        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    public func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.empty)
            return
        }
        
        do {
            let decoder = try JSONDecoder().decode(Cache.self, from: data)
            completion(.find(decoder.localFeed, decoder.timestamp))
        } catch {
            completion(.failure(error))
        }
        
    }
    
    public func insert(_ feed: [LocalFeedImage], currentDate: Date, completion: @escaping FeedStore.InsertionCompletion) {
        do {
            let encoder = try JSONEncoder().encode(Cache(feed: feed.map(CodableFeedImage.init), timestamp: currentDate))
            try encoder.write(to: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    public func deleteCacheFeed(completion: @escaping FeedStore.DeletionCompletion) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            completion(nil)
            return
        }
        do {
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}
