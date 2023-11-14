//
//  SharedLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 03/10/2023.
//

import XCTest
import EssentialFeed
import TestHelpers

final class SharedLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let bundle = EssentialFeed.bundle
        
        assertLocalizationKeysAndValuesExist(in: bundle, table)
    }
}
