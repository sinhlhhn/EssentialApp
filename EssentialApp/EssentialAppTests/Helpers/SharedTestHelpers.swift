//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Sam on 21/09/2023.
//

import Foundation

func anyURL() -> URL {
    return URL(string: "https://any-url")!
}

func anyNSError() -> NSError {
    return NSError(domain: "0", code: 0)
}

func anyData() -> Data {
    return Data("any-data".utf8)
}
