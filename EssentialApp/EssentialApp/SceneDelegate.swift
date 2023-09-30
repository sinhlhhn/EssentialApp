//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Sam on 21/09/2023.
//

import UIKit
import Combine
import CoreData
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private lazy var client: HTTPClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    
    private lazy var store: (FeedStore & FeedImageDataStore) = {
        let localStoreURL = NSPersistentContainer.defaultDirectoryURL().appending(path: "feed-store.sqplite")
        return try! CoreDataFeedStore(storeURL: localStoreURL)
    }()
    
    private lazy var localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
    
    private lazy var remoteFeedLoader: RemoteLoader<[FeedImage]> = {
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        return RemoteLoader(client: client, url: url, mapper: FeedItemsMapper.map)
    }()

    convenience init(client: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.client = client
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        
        configureWindow()
    }
    
    func configureWindow() {
        let feedViewController = UINavigationController(rootViewController: FeedUIComposer.feedComposedWith(
            loader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeLocalFeedImageLoaderWithRemoteFallback))
        
        window?.rootViewController = feedViewController
        
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> RemoteLoader<[FeedImage]>.Publisher {
        return remoteFeedLoader
            .loadPublisher()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }
    
    private func makeLocalFeedImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        let localImageFeedLoader = LocalFeedImageDataLoader(store: store)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: client)
        
        return localImageFeedLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: {
                remoteImageLoader.loadImageDataPublisher(from: url)
                    .caching(to: localImageFeedLoader, using: url)
            })
    }
}

extension RemoteLoader: FeedLoader where Resource == [FeedImage] {}
