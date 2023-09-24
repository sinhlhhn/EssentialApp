//
//  EssentialAppUIAcceptanceTests.swift
//  EssentialAppUIAcceptanceTests
//
//  Created by Sam on 23/09/2023.
//

import XCTest

final class EssentialAppUIAcceptanceTests: XCTestCase {
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        
        app.launch()
        sleep(5)
        
        XCTAssertEqual(app.tables.count, 1)
        XCTAssertEqual(app.tables.cells.count, 22)
    }
}
