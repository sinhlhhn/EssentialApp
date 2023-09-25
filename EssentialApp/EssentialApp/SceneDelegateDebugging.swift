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
        if let connectivity = UserDefaults.standard.string(forKey: "connectivity") {
            return DebuggingHTTPClient(connectivity: connectivity)
        }
        
        return super.makeRemoteClient()
    }
}

#if DEBUG
private class DebuggingHTTPClient: HTTPClient {
    private let connectivity: String
    
    init(connectivity: String) {
        self.connectivity = connectivity
    }
    
    private class Task: HTTPClientTask {
        func cancel() { }
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> EssentialFeed.HTTPClientTask {
        if connectivity == "offline" {
            let error = NSError(domain: "always failed", code: 0)
            completion(.failure(error))
        } else {
            completion(.success(makeSuccessfulResponse(for: url)))
        }
        
        return Task()
    }
    
    private func makeSuccessfulResponse(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let data = makeData(for: url)
        
        return (data, response)
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "http://image.com":
            return makeImageData()
        default:
            return makeFeedData()
        }
    }
    
    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject:
        [
            "items":
                [
                    ["id": UUID().uuidString, "image": "http://image.com"],
                    ["id": UUID().uuidString, "image": "http://image.com"]
                ]
        ])
    }
    
    private func makeImageData() -> Data {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.red.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!.pngData()!
    }
}
#endif
