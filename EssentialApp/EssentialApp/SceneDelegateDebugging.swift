//
//  SceneDelegateDebugging.swift
//  EssentialApp
//
//  Created by Sam on 25/09/2023.
//

import Foundation
import UIKit
import EssentialFeed

class SceneDelegateDebugging: SceneDelegate {
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        #if DEBUG
        if CommandLine.arguments.contains("-reset") {
            try! FileManager.default.removeItem(at: localStoreURL)
        }
        #endif
        
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
    
    override func makeRemoteClient() -> HTTPClient {
        #if DEBUG
        if UserDefaults.standard.string(forKey: "connectivity") == "offline" {
            return AlwaysFallHTTPClient()
        }
        #endif
        
        return super.makeClient()
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
