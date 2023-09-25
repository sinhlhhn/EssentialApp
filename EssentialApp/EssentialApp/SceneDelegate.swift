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
    
    let localStoreURL = NSPersistentContainer.defaultDirectoryURL().appending(path: "feed-store.sqplite")
    
    private lazy var client: HTTPClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    
    private lazy var store: (FeedStore & FeedImageDataStore) = {
        
        return try! CoreDataFeedStore(storeURL: localStoreURL)
    }()

    convenience init(client: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.client = client
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
        configureWindow()
    }
    
    func configureWindow() {
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        
        let remoteImageLoader = RemoteFeedImageDataLoader(client: client)
        let remoteFeedLoader = RemoteFeedLoader(client: client, url: url)
        
        let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
        let localImageFeedLoader = LocalFeedImageDataLoader(store: store)
        
        let feedViewController = UINavigationController(rootViewController: FeedUIComposer.feedComposedWith(
            loader: FeedLoaderWithFallbackComposite(
                primaryLoader: FeedLoaderCacheDecorator(
                    decoratee: remoteFeedLoader,
                    cache: localFeedLoader),
                fallbackLoader: localFeedLoader),
            imageLoader: FeedImageDataLoaderWithFallbackComposite(
                primaryLoader: FeedImageDataLoaderCacheDecorator(
                    decoratee: remoteImageLoader,
                    cache: localImageFeedLoader),
                fallbackLoader: localImageFeedLoader)))
        
        window?.rootViewController = feedViewController
    }
    
    func makeRemoteClient() -> HTTPClient {
        let session = URLSession(configuration: .ephemeral)
        return URLSessionHTTPClient(session: session)
    }
}
