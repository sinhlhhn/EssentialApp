//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 14/09/2023.
//

import Foundation
import XCTest
import EssentialFeed

final class FeedImagePresenterTests: XCTestCase {
    
    func test_map_createsViewModel() {
        let image = uniqueImage()
        
        let result = FeedImagePresenter.map(image)
        
        XCTAssertEqual(result.location, image.location)
        XCTAssertEqual(result.description, image.description)
    }
}
