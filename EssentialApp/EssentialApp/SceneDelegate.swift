//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Sam on 21/09/2023.
//

import UIKit
import CoreData
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let client = makeClient()
        let remoteImageLoader = RemoteFeedImageDataLoader(client: client)
        let remoteFeedLoader = RemoteFeedLoader(client: client, url: url)
        
        var localStoreURL = NSPersistentContainer.defaultDirectoryURL()
                localStoreURL.append(path: "feed-store.sqplite")

        #if DEBUG
        if CommandLine.arguments.contains("-reset") {
            try! FileManager.default.removeItem(at: localStoreURL)
        }
        #endif
        
        let store = try! CoreDataFeedStore(storeURL: localStoreURL)
        let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
        let localImageFeedLoader = LocalFeedImageDataLoader(store: store)
        
        let feedViewController = FeedUIComposer.feedComposedWith(
            loader: FeedLoaderWithFallbackComposite(
                primaryLoader: remoteFeedLoader,
                fallbackLoader: localFeedLoader),
            imageLoader: FeedImageDataLoaderWithFallbackComposite(
                primaryLoader: remoteImageLoader,
                fallbackLoader: localImageFeedLoader))
        
        window?.rootViewController = feedViewController
    }
    
    private func makeClient() -> HTTPClient {
        #if DEBUG
        if UserDefaults.standard.string(forKey: "connectivity") == "offline" {
            return AlwaysFallHTTPClient()
        }
        #endif
        
        let session = URLSession(configuration: .ephemeral)
        return URLSessionHTTPClient(session: session)
    }
}
#if DEBUG
private class AlwaysFallHTTPClient: HTTPClient {
    
    private class Task: HTTPClientTask {
        func cancel() { }
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> EssentialFeed.HTTPClientTask {
        let error = NSError(domain: "always failed", code: 0)
        completion(.failure(error))
        return Task()
    }
}
#endif
