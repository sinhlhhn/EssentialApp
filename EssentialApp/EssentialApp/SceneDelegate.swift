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
    
    private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    
    private lazy var navigationController = UINavigationController(rootViewController: FeedUIComposer.feedComposedWith(
        loader: makeRemoteFeedLoaderWithLocalFallback,
        imageLoader: makeLocalFeedImageLoaderWithRemoteFallback,
        selection: showComments))
    
    private lazy var localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)

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
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
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
        return client
            .getPublisher(from: url)
            .tryMap(FeedItemsMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map { [unowned self] items in
                Paginated(items: items, loadMorePublisher: self.makeRemoteLoadMoreLoader(items: items, last: items.last))
            }
            .eraseToAnyPublisher()
    }
    
    private func makeRemoteLoadMoreLoader(items: [FeedImage], last: FeedImage?) -> (() -> AnyPublisher<Paginated<FeedImage>, Error>)? {
        return last.map { lastItem in
            let url = FeedEndpoint.get(after: lastItem).url(baseURL: baseURL)
            return { [client] in
                client.getPublisher(from: url)
                    .tryMap(FeedItemsMapper.map)
                    .map { [unowned self] newItems in
                        let allItems = items + newItems
                        return Paginated(items: allItems, loadMorePublisher: self.makeRemoteLoadMoreLoader(items: allItems, last: newItems.last))
                    }.eraseToAnyPublisher()
            }
        }
    }
    
    private func makeLocalFeedImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        let localImageFeedLoader = LocalFeedImageDataLoader(store: store)
        let fallbackImageFeedLoader = client.getPublisher(from: url)
            .tryMap(FeedImageDataMapper.map)
            .caching(to: localImageFeedLoader, using: url)
        
        return localImageFeedLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: {
                return fallbackImageFeedLoader
            })
    }
}
