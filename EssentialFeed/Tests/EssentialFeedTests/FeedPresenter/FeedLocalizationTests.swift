//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Sam on 12/09/2023.
//

import Foundation
import XCTest
import EssentialFeed
import TestHelpers

final class FeedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = EssentialFeed.bundle
        
        assertLocalizationKeysAndValuesExist(in: bundle, table)
    }
    
}
