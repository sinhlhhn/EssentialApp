//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 04/10/2023.
//

import Foundation
import XCTest
import EssentialFeed

final class ImageCommentsLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        
        assertLocalizationKeysAndValuesExist(in: bundle, table)
    }
    
}
