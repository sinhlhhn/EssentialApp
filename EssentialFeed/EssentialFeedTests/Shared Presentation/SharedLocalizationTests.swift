//
//  SharedLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 03/10/2023.
//

import XCTest
import EssentialFeed

final class SharedLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let bundle = Bundle(for: LoadResourcePresenter<String, DummyView>.self)
        
        assertLocalizationKeysAndValuesExist(in: bundle, table)
    }
    
    //MARK: -Helpers
    
    private class DummyView: ResourceView {
        func display(_ viewModel: String) {}
    }
}
