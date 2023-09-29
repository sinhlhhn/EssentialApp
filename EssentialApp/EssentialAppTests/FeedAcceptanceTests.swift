//
//  FeedAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by Sam on 25/09/2023.
//

import XCTest
import EssentialFeediOS
import EssentialFeed
@testable import EssentialApp

final class FeedAcceptanceTests: XCTestCase {
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let feed = launch(store: .empty, client: .online(makeSuccessfulResponse))
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(feed.renderedImage(at: 0), makeImageData())
        XCTAssertEqual(feed.renderedImage(at: 1), makeImageData())
    }
    
    func test_onLaunch_displaysCachedFeedWhenCustomerHasNoConnectivity() {
        let sharedStore = InMemoryFeedStore.empty
        let onlineFeed = launch(store: sharedStore, client: .online(makeSuccessfulResponse))
        onlineFeed.simulateFeedImageViewVisible(at: 0)
        onlineFeed.simulateFeedImageViewVisible(at: 1)
        
        let offlineFeed = launch(store: sharedStore, client: .offline)
        XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(offlineFeed.renderedImage(at: 0), makeImageData())
        XCTAssertEqual(offlineFeed.renderedImage(at: 1), makeImageData())
    }
    
    func test_onLaunch_displaysEmptyWhenCustomerHasNoConnectivityAndNoCached() {
        let offlineFeed = launch(store: .empty, client: .offline)
        
        XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews(), 0)
    }
    
    func test_onEnteringBackground_deletesExpiredFeedCached() {
        let store = InMemoryFeedStore.withExpiredFeedCache
        
        enteringBackground(with: store)
        
        XCTAssertNil(store.feedCache)
    }
    
    func test_onEnteringBackground_doesNotDeleteNonExpiredFeedCached() {
        let store = InMemoryFeedStore.withNonExpiredFeedCache
        
        enteringBackground(with: store)
        
        XCTAssertNotNil(store.feedCache)
    }
    
    //MARK: -Helpers
    
    private func launch(
        store: InMemoryFeedStore = .empty,
        client: HTTPClientStub = HTTPClientStub.offline
    ) -> FeedViewController {
        
        let sut = SceneDelegate(client: client, store: store)
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        let feedViewController = nav?.topViewController as! FeedViewController
        
        return feedViewController
    }
    
    private func enteringBackground(with store: InMemoryFeedStore) {
        let sut = SceneDelegate(client: HTTPClientStub.offline, store: store)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
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
        UIImage.make(with: .red).pngData()!
    }
}
