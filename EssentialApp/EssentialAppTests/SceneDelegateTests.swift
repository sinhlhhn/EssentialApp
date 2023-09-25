//
//  SceneDelegateTests.swift
//  EssentialAppTests
//
//  Created by Sam on 25/09/2023.
//

import XCTest
import EssentialFeediOS
@testable import EssentialApp

final class SceneDelegateTests: XCTestCase {
    func test_sceneWillConnectToSession_configuresRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        sut.configureWindow()
        
        let root = sut.window?.rootViewController as? UINavigationController
        let topViewController = root?.topViewController
        XCTAssertNotNil(root, "Expected navigation controller as root, got \(String(describing: root)) instead")
        XCTAssertTrue(topViewController is FeedViewController, "Expected FeedViewController as top view controller, got \(String(describing: topViewController)) intead")
    }
}
