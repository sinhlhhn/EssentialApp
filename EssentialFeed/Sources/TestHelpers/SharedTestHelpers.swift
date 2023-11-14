//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Sam on 18/08/2023.
//

import Foundation

public func anyNSError() -> NSError {
    NSError(domain: "any-error", code: 1)
}

public func anyURL() -> URL {
    URL(string: "http://any-url")!
}

public func anyData() -> Data {
    Data("any-data".utf8)
}

public func makeItemJSON(_ items: [[String: Any]]) -> Data {
    let json = [
        "items": items
    ]
    return try! JSONSerialization.data(withJSONObject: json)
}

public func response(with statusCode: Int) -> HTTPURLResponse {
    return HTTPURLResponse(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}

public func anyHTTPURLResponse() -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
}

public extension Date {
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
    
    func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        calendar.date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(minutes: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        calendar.date(byAdding: .minute, value: minutes, to: self)!
    }
}
