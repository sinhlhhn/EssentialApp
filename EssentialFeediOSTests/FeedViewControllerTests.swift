//
//  FeedViewControllerTests.swift
//  FeedViewControllerTests
//
//  Created by Sam on 31/08/2023.
//

import XCTest

final class FeedViewController: UIViewController {
    var loader: LoaderSpy?
    
    convenience init(loader: LoaderSpy) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader?.load()
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoad() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    //MARK: -Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(loader)
        
        return (sut, loader)
    }
}

class LoaderSpy {
    var loadCallCount = 0
    
    func load() {
        loadCallCount += 1
    }
}
