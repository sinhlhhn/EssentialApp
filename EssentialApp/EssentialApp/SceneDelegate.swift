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
    
    private lazy var remoteFeedLoader: RemoteFeedLoader = {
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        return RemoteFeedLoader(client: client, url: url)
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
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> RemoteFeedLoader.Publisher {
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

extension FeedImageDataLoader {
    public typealias Publisher = AnyPublisher<Data, Error>
    
    public func loadImageDataPublisher(from url: URL) -> Publisher {
        var task: FeedImageDataLoaderTask?
        
        return Deferred {
            Future { completion in
                task = self.loadImageData(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

extension FeedLoader {
    public typealias Publisher = AnyPublisher<[FeedImage], Error>
    
    public func loadPublisher() -> Publisher {
        return Deferred {
            Future(self.load)
        }
        .eraseToAnyPublisher()
    }
}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
}

extension Publisher where Output == [FeedImage] {
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: cache.saveIgnoringResult).eraseToAnyPublisher()
    }
}

private extension FeedImageDataCache {
    func saveIgnoringResult(with data: Data, from url: URL) {
        save(data, for: url) { _ in }
    }
}

extension Publisher where Output == Data {
    func caching(to cache: FeedImageDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { data in
            cache.saveIgnoringResult(with: data, from: url)
        }).eraseToAnyPublisher()
    }
}

extension Publisher {
    func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
    }
}

extension Publisher {
    func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
        return receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
    }
}

extension DispatchQueue {
    
    static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
        return ImmediateWhenOnMainQueueScheduler()
    }
    
    class ImmediateWhenOnMainQueueScheduler: Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions
        
        var now: SchedulerTimeType {
            return DispatchQueue.main.now
        }

        var minimumTolerance: SchedulerTimeType.Stride {
            return DispatchQueue.main.minimumTolerance
        }

        func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
            if Thread.isMainThread {
                action()
            } else {
                DispatchQueue.main.schedule(options: options, action)
            }
        }

        func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }

        func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }
    }
}
