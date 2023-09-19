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
