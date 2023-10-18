//
//  CommentsEndpointTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 17/10/2023.
//

import XCTest
import EssentialFeed

final class CommentsEndpointTests: XCTestCase {
    func test_comments_endpointURL() {
        let imageID = UUID(uuidString: "2239CBA2-CB35-4392-ADC0-24A37D38E010")!
        let baseURL = URL(string: "http://base-url.com")!
        
        let receive = CommentsEndpoint.get(imageID).url(baseURL: baseURL)
        let expected = URL(string: "http://base-url.com/v1/image/2239CBA2-CB35-4392-ADC0-24A37D38E010/comments")!
        
        XCTAssertEqual(receive, expected)
    }
}
