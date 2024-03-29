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

func anyHTTPURLResponse() -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
}

extension Date {
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
