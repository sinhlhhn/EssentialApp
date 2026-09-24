//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Sam on 21/09/2023.
//

import UIKit
import os
import Combine
import CoreData
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    // These services are only ever mutated during setup/testing (before use) and are read-only
    // afterwards, but they're intentionally accessed from background queues (see `.subscribe(on:
    // scheduler)` below), so opt them out of this MainActor-isolated class's actor isolation.
    // `nonisolated(unsafe)` isn't supported on `lazy var` (no synchronized backing storage), so
    // these are computed eagerly in `init()` instead.
    private nonisolated(unsafe) var scheduler: AnyDispatchQueueScheduler
    
    private let logger: Logger
    
    private nonisolated let client: HTTPClient
    
    private nonisolated let store: FeedStore & FeedImageDataStore
    
    private nonisolated let baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    
    private nonisolated let localFeedLoader: LocalFeedLoader
    
    private lazy var navigationController = UINavigationController(rootViewController: FeedUIComposer.feedComposedWith(
        loader: makeRemoteFeedLoaderWithLocalFallback,
        imageLoader: makeLocalFeedImageLoaderWithRemoteFallback,
        selection: showComments))
    
    override init() {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        
        let scheduler: AnyDispatchQueueScheduler = DispatchQueue(
            label: "com.sinhlh.infra.queue",
            qos: .userInitiated,
            attributes: .concurrent)
        .eraseToAnyScheduler()
        
        let logger = Logger(subsystem: "com.sinhlh.essentialFeed", category: "main")
        let store: FeedStore & FeedImageDataStore
        do {
            let localStoreURL = NSPersistentContainer.defaultDirectoryURL().appending(path: "feed-store.sqplite")
            store = try CoreDataFeedStore(storeURL: localStoreURL)
        } catch {
            assertionFailure("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            logger.fault("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            store = NullStore()
        }
        
        self.client = client
        self.logger = logger
        self.scheduler = scheduler
        self.store = store
        self.localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
        
        super.init()
    }

    init(client: HTTPClient, store: FeedStore & FeedImageDataStore, scheduler: AnyDispatchQueueScheduler) {
        
        let logger = Logger(subsystem: "com.sinhlh.essentialFeed", category: "main")
        
        self.client = client
        self.store = store
        self.scheduler = scheduler
        self.logger = logger
        self.scheduler = scheduler
        self.localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        
        configureWindow()
    }
    
    func configureWindow() {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        do {
            try localFeedLoader.validateCache()
        } catch {
            logger.error("Failed to validate cache with error: \(error.localizedDescription)")
        }
    }
    
    private func showComments(image: FeedImage) {
        let url = CommentsEndpoint.get(image.id).url(baseURL: baseURL)
        
        let commentsVC = CommentsUIComposer.commentsComposedWith(loader: makeRemoteCommentsLoader(url: url))
        
        navigationController.pushViewController(commentsVC, animated: true)
    }
    
    private nonisolated func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
        return { [client] in
            client
                .getPublisher(from: url)
                .tryMap(ImageCommentsMapper.map)
                .eraseToAnyPublisher()
        }
    }
    
    private nonisolated func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
        let url = FeedEndpoint.get().url(baseURL: baseURL)
        return makeRemoteFeedLoader(url: url)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map(makeFirstPage)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private nonisolated func makeRemoteLoadMoreLoader(last: FeedImage?) -> AnyPublisher<Paginated<FeedImage>, Error> {
        let url = FeedEndpoint.get(after: last).url(baseURL: baseURL)
        return makeRemoteFeedLoader(url: url)
            .zip(localFeedLoader.loadPublisher())
            .map { (newItems, cachedItems) in
                (cachedItems + newItems, newItems.last)
            }
            .map(makePage)
            .caching(to: localFeedLoader)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private nonisolated func makeRemoteFeedLoader(url: URL) -> AnyPublisher<[FeedImage], Error> {
        return client
            .getPublisher(from: url)
            .tryMap(FeedItemsMapper.map)
            .eraseToAnyPublisher()
    }
    
    private nonisolated func makeFirstPage(items: [FeedImage]) -> Paginated<FeedImage> {
        makePage(items: items, last: items.last)
    }
    
    private nonisolated func makePage(items: [FeedImage] ,last: FeedImage?) -> Paginated<FeedImage> {
        Paginated(items: items, loadMorePublisher: last.map { last in
            { self.makeRemoteLoadMoreLoader(last: last) }
        })
    }
    
    private nonisolated func makeLocalFeedImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        let localImageFeedLoader = LocalFeedImageDataLoader(store: store)
        let fallbackImageFeedLoader = client.getPublisher(from: url)
            .tryMap(FeedImageDataMapper.map)
            .caching(to: localImageFeedLoader, using: url)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
        
        return localImageFeedLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: {
                return fallbackImageFeedLoader
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
}
