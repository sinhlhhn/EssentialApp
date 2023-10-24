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
        XCTAssertEqual(feed.renderedImage(at: 0), makeImageData1())
        XCTAssertEqual(feed.renderedImage(at: 1), makeImageData2())
        XCTAssertTrue(feed.canLoadMoreFeed)
        
        feed.simulateLoadMoreFeedAction()
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 3)
        XCTAssertEqual(feed.renderedImage(at: 0), makeImageData1())
        XCTAssertEqual(feed.renderedImage(at: 1), makeImageData2())
        XCTAssertEqual(feed.renderedImage(at: 2), makeImageData3())
        XCTAssertTrue(feed.canLoadMoreFeed)
        
        feed.simulateLoadMoreFeedAction()
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 3)
        XCTAssertEqual(feed.renderedImage(at: 0), makeImageData1())
        XCTAssertEqual(feed.renderedImage(at: 1), makeImageData2())
        XCTAssertEqual(feed.renderedImage(at: 2), makeImageData3())
        XCTAssertFalse(feed.canLoadMoreFeed)
    }
    
    func test_onLaunch_displaysCachedFeedWhenCustomerHasNoConnectivity() {
        let sharedStore = InMemoryFeedStore.empty
        let onlineFeed = launch(store: sharedStore, client: .online(makeSuccessfulResponse))
        onlineFeed.simulateFeedImageViewVisible(at: 0)
        onlineFeed.simulateFeedImageViewVisible(at: 1)
        
        onlineFeed.simulateLoadMoreFeedAction()
        onlineFeed.simulateFeedImageViewVisible(at: 2)
        
        let offlineFeed = launch(store: sharedStore, client: .offline)
        XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews(), 3)
        XCTAssertEqual(offlineFeed.renderedImage(at: 0), makeImageData1())
        XCTAssertEqual(offlineFeed.renderedImage(at: 1), makeImageData2())
        XCTAssertEqual(offlineFeed.renderedImage(at: 2), makeImageData3())
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
    
    func test_onFeedImageSelection_displaysComments() {
        let comments = showCommentsForFirstImage()
        
        XCTAssertEqual(comments.numberOfRenderedComments(), 1)
        XCTAssertEqual(comments.commentMessage(at: 0), makeCommentMessage())
    }
    
    //MARK: -Helpers
    
    private func launch(
        store: InMemoryFeedStore = .empty,
        client: HTTPClientStub = HTTPClientStub.offline
    ) -> ListViewController {
        
        let sut = SceneDelegate(client: client, store: store)
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        let feedViewController = nav?.topViewController as! ListViewController
        
        return feedViewController
    }
    
    private func showCommentsForFirstImage() -> ListViewController {
        let feed = launch(store: .empty, client: .online(makeSuccessfulResponse))
        
        feed.simulateTapFeedImage(at: 0)
        RunLoop.current.run(until: Date())
        
        let nav = feed.navigationController
        
        return nav?.topViewController as! ListViewController
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
        switch url.path {
        case "/image-1": return makeImageData1()
        case "/image-2": return makeImageData2()
        case "/image-3": return makeImageData3()
            
        case "/essential-feed/v1/feed" where url.query()?.contains("after_id") == false:
            return makeFirstFeedDataPage()
            
        case "/essential-feed/v1/feed" where url.query()?.contains("after_id=A28F5FE3-27A7-44E9-8DF5-53742D0E4A5A") == true:
            return makeSecondFeedDataPage()
            
        case "/essential-feed/v1/feed" where url.query()?.contains("after_id=99CCBA00-7187-11EE-B962-0242AC120002") == true:
            return makeLastEmptyFeedDataPage()
            
        case "/essential-feed/v1/image/2AB2AE66-A4B7-4A16-B374-51BBAC8DB086/comments":
            return makeCommentsData()
        default:
            return Data()
        }
    }

    private func makeFirstFeedDataPage() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": "2AB2AE66-A4B7-4A16-B374-51BBAC8DB086", "image": "http://feed.com/image-1"],
            ["id": "A28F5FE3-27A7-44E9-8DF5-53742D0E4A5A", "image": "http://feed.com/image-2"]
        ]])
    }
    
    private func makeSecondFeedDataPage() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": "99CCBA00-7187-11EE-B962-0242AC120002", "image": "http://feed.com/image-3"]
        ]])
    }
    
    private func makeLastEmptyFeedDataPage() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [[String: Any]]()])
    }
    
    private func makeCommentsData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            [
                "id": UUID().uuidString,
                "message": makeCommentMessage(),
                "created_at": "2020-05-20T11:24:59+0000",
                "author": [
                    "username": "a username"
                ]
            ] as [String : Any],
        ]])
    }
    
    private func makeImageData1() -> Data {
        UIImage.make(with: .red).pngData()!
    }
    
    private func makeImageData2() -> Data {
        UIImage.make(with: .green).pngData()!
    }
    
    private func makeImageData3() -> Data {
        UIImage.make(with: .blue).pngData()!
    }
    
    private func makeCommentMessage() -> String {
        return "a message"
    }
}
