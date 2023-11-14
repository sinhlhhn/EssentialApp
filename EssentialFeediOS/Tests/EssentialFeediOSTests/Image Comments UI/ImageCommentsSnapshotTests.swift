//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Sam on 25/09/2023.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class ImageCommentsSnapshotTests: XCTestCase {
    
    func test_imageCommentsWithContent() {
        let sut = makeSUT()
        sut.display(comments())
        
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .light)), name: "IMAGE_COMMENTS_light")
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .dark)), name: "IMAGE_COMMENTS_dark")
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .light, contentSize: .extraExtraExtraLarge)), name: "IMAGE_COMMENTS_light_extraExtraExtraLarge")
    }
    
    //MARK: -Helpers
    
    private func makeSUT() -> ListViewController {
        let bundle = EssentialFeediOS.bundle
        let sb = UIStoryboard(name: "ImageComments", bundle: bundle)
        let sut = sb.instantiateViewController(identifier: "ImageCommentsViewController") as! ListViewController
        sut.loadViewIfNeeded()
        sut.tableView.showsVerticalScrollIndicator = false
        sut.tableView.showsHorizontalScrollIndicator = false
        
        return sut
    }
    
    private func comments() -> [CellController] {
        commentsCellController().map { CellController(id: UUID(), $0)}
    }
    
    private func commentsCellController() -> [ImageCommentCellController] {
        return [
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                    date: "1000 years ago",
                    username: "a long long long long username"
                )
            ),
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "East Side Gallery\nMemorial in Berlin, Germany",
                    date: "10 days ago",
                    username: "a username"
                )
            ),
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "nice",
                    date: "1 hour ago",
                    username: "a."
                )
            ),
        ]
    }
}
