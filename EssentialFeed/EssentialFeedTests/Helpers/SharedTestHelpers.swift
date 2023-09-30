//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Sam on 18/08/2023.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any-error", code: 1)
}

func anyURL() -> URL {
    URL(string: "http://any-url")!
}

func anyData() -> Data {
    Data("any-data".utf8)
}

func makeItemJSON(_ items: [[String: Any]]) -> Data {
    let json = [
        "items": items
    ]
    return try! JSONSerialization.data(withJSONObject: json)
}

func response(with statusCode: Int) -> HTTPURLResponse {
    return HTTPURLResponse(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}
