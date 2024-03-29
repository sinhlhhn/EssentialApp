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
    
    private lazy var scheduler: AnyDispatchQueueScheduler = DispatchQueue(
        label: "com.sinhlh.infra.queue",
        qos: .userInitiated,
        attributes: .concurrent)
    .eraseToAnyScheduler()
    
    private lazy var logger = Logger(subsystem: "com.sinhlh.essentialFeed", category: "main")
    
    private lazy var client: HTTPClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    
    private lazy var store: (FeedStore & FeedImageDataStore) = {
        let localStoreURL = NSPersistentContainer.defaultDirectoryURL().appending(path: "feed-store.sqplite")
        do {
            return try CoreDataFeedStore(storeURL: localStoreURL)
        } catch {
            assertionFailure("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            logger.fault("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            return NullStore()
        }
    }()
    
    private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    
    private lazy var navigationController = UINavigationController(rootViewController: FeedUIComposer.feedComposedWith(
        loader: makeRemoteFeedLoaderWithLocalFallback,
        imageLoader: makeLocalFeedImageLoaderWithRemoteFallback,
        selection: showComments))
    
    private lazy var localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)

    convenience init(client: HTTPClient, store: FeedStore & FeedImageDataStore, scheduler: AnyDispatchQueueScheduler) {
        self.init()
        self.client = client
        self.store = store
        self.scheduler = scheduler
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
    
    private func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
        return { [client] in
            client
                .getPublisher(from: url)
                .tryMap(ImageCommentsMapper.map)
                .eraseToAnyPublisher()
        }
    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
        let url = FeedEndpoint.get().url(baseURL: baseURL)
        return makeRemoteFeedLoader(url: url)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map(makeFirstPage)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeRemoteLoadMoreLoader(last: FeedImage?) -> AnyPublisher<Paginated<FeedImage>, Error> {
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
    
    private func makeRemoteFeedLoader(url: URL) -> AnyPublisher<[FeedImage], Error> {
        return client
            .getPublisher(from: url)
            .tryMap(FeedItemsMapper.map)
            .eraseToAnyPublisher()
    }
    
    private func makeFirstPage(items: [FeedImage]) -> Paginated<FeedImage> {
        makePage(items: items, last: items.last)
    }
    
    private func makePage(items: [FeedImage] ,last: FeedImage?) -> Paginated<FeedImage> {
        Paginated(items: items, loadMorePublisher: last.map { last in
            { self.makeRemoteLoadMoreLoader(last: last) }
        })
    }
    
    private func makeLocalFeedImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
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
