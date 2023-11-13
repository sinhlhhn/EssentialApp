//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Sam on 12/09/2023.
//

import Foundation
import XCTest
import EssentialFeed

final class FeedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        
        assertLocalizationKeysAndValuesExist(in: bundle, table)
    }
    
}
