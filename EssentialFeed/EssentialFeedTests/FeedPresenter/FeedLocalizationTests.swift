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
        let presentationBundle = Bundle(for: FeedPresenter.self)
        let localizationBundles = allLocalizationBundles(in: presentationBundle)
        let localizedStringKeys = allLocalizedStringKeys(in: localizationBundles, table: table)
        
        localizationBundles.forEach { bundle, localization in
            localizedStringKeys.forEach { key in
                let localizedStrings = bundle.localizedString(forKey: key, value: nil, table: table)
                if localizedStrings == key {
                    let language = Locale.current.localizedString(forIdentifier: localization) ?? ""
                    
                    XCTFail("Missing \(language) \(localization) localized string for key: \(key) in table: \(table)")
                }
            }
        }
    }
    
    //MARK: -Helpers
    
    private typealias LocalizedBundle = (bundle: Bundle, localization: String)
    
    private func allLocalizationBundles(in bundle: Bundle, file: StaticString = #filePath, line: UInt = #line) -> [LocalizedBundle] {
        return bundle.localizations.compactMap { localization in
            guard let path = bundle.path(forResource: localization, ofType: "lproj"),
                  let localizedBundle = Bundle(path: path) else {
                XCTFail("Couldn't fine bundle for localization: \(localization)", file: file, line: line)
                return nil
            }
            return (localizedBundle, localization)
        }
    }
    
    private func allLocalizedStringKeys(in bundles: [LocalizedBundle], table: String, file: StaticString = #filePath, line: UInt = #line) -> Set<String> {
        return bundles.reduce([]) { (acc, current) in
            guard let path = current.bundle.path(forResource: table, ofType: "strings"),
                  let strings = NSDictionary(contentsOfFile: path),
                  let keys = strings.allKeys as? [String] else {
                XCTFail("Couldn't load localized strings for localization: \(current.localization)", file: file, line: line)
                return acc
            }
            return acc.union(Set(keys))
        }
    }
}
