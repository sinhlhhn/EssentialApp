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
    
    var localStoreURL = NSPersistentContainer.defaultDirectoryURL().appending(path: "feed-store.sqplite")

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let client = makeRemoteClient()
        let remoteImageLoader = RemoteFeedImageDataLoader(client: client)
        let remoteFeedLoader = RemoteFeedLoader(client: client, url: url)
        
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
    
    func makeRemoteClient() -> HTTPClient {
        let session = URLSession(configuration: .ephemeral)
        return URLSessionHTTPClient(session: session)
    }
}
