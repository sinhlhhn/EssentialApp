//
//  FeedViewControllerTests.swift
//  FeedViewControllerTests
//
//  Created by Sam on 31/08/2023.
//

import XCTest

final class FeedViewController {
    init(loader: LoaderSpy) {
        
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoad() {
        let loader = LoaderSpy()
        let _ = FeedViewController(loader: loader)
        
        loader.load()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    
}

class LoaderSpy {
    var loadCallCount = 0
    
    func load() {
        
    }
}
