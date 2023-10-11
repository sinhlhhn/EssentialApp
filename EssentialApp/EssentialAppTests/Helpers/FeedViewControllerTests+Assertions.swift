//
//  FeedViewControllerTests+Assertions.swift
//  EssentialFeediOSTests
//
//  Created by Sam on 08/09/2023.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

extension FeedUIIntegrationTests {
    
    func assertThat(_ sut: ListViewController, isRendering images: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        sut.view.enforceLayoutCycle()
        
        guard sut.numberOfRenderedFeedImageViews() == images.count else {
            XCTFail("Expected \(images.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead", file: file, line: line)
            return
        }
        
        images.enumerated().forEach {
            assertThat(sut, hasViewConfigFor: $0.element, in: $0.offset, file: file, line: line)
        }
    }
    
    func assertThat(_ sut: ListViewController, hasViewConfigFor image: FeedImage, in index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
            return
        }
        
        let shouldLocationBeVisible = image.location != nil
        XCTAssertEqual(cell.isShowLocation, shouldLocationBeVisible, "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index \(index) got \(cell.isShowLocation) instead", file: file, line: line)
        XCTAssertEqual(cell.locationText, image.location, "Expected `locationText` to be \(String(describing: image.location)) for image view at index \(index) got \(String(describing: cell.locationText)) instead", file: file, line: line)
        let shouldDescriptionBeVisible = image.description != nil
        XCTAssertEqual(cell.isShowDescription, shouldDescriptionBeVisible,  "Expected `isShowDescription` to be \(shouldDescriptionBeVisible) for image view at index \(index) got \(cell.isShowDescription) instead", file: file, line: line)
        XCTAssertEqual(cell.descriptionText, image.description, "Expected `descriptionText` to be \(String(describing: image.description)) for image view at index \(index) got \(String(describing: cell.descriptionText)) instead", file: file, line: line)
    }
}
