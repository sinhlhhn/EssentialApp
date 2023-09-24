//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Sam on 21/09/2023.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: client)
        let remoteFeedLoader = RemoteFeedLoader(client: client, url: url)
        
        let feedViewController = FeedUIComposer.feedComposedWith(
            loader: remoteFeedLoader,
            imageLoader: remoteImageLoader)
        
        window?.rootViewController = feedViewController
    }
}

