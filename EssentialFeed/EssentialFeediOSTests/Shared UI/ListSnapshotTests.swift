//
//  ListSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Sam on 11/10/2023.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class ListSnapshotTests: XCTestCase {
    
    func test_emptyList() {
        let sut = makeSUT()
        sut.display(emptyList())
        
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .light)), name: "EMPTY_LIST_light")
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .dark)), name: "EMPTY_LIST_dark")
    }
    
    func test_listWithError() {
        let sut = makeSUT()
        sut.display(.error(message: "There is a\nmulti-line\nerror message"))
        
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .light)), name: "LIST_WITH_ERROR_MESSAGE_light")
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .dark)), name: "LIST_WITH_ERROR_MESSAGE_dark")
    }
    
    //MARK: -Helpers
    
    private func makeSUT() -> ListViewController {
        let sut = ListViewController()
        sut.loadViewIfNeeded()
        sut.tableView.showsVerticalScrollIndicator = false
        sut.tableView.showsHorizontalScrollIndicator = false
        
        return sut
    }
    
    private func emptyList() -> [CellController] {
        return []
    }
}
