//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 14/09/2023.
//

import Foundation
import XCTest
import EssentialFeed

struct FeedImageViewModel {
    let image: Any?
    let shouldRetry: Bool
    let isLoading: Bool
    let location: String?
    let description: String?
}

protocol FeedImageView {
    func display(_ viewModel: FeedImageViewModel)
}

final class FeedImagePresenter {
    var imageTransformer: (Data) -> Any?
    var view: FeedImageView
    
    init(view: FeedImageView, imageTransformer: @escaping (Data) -> Any?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    private struct InvalidImageDataError: Error {}
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModel(image: nil, shouldRetry: false, isLoading: true, location: model.location, description: model.description))
    }
    
    func didFinishLoadingImageData(with: Error, for model: FeedImage) {
        view.display(FeedImageViewModel(image: nil, shouldRetry: true, isLoading: false, location: model.location, description: model.description))
    }
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
    }
}

final class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendMessage() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    func test_didStartLoadingImageData_displaysLoadingImage() {
        let image = uniqueImage()
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingImageData(for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImageData_displaysRetry() {
        let image = uniqueImage()
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingImageData(with: anyError(), for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImageData_displaysRetryOnInValidImageData() {
        let image = uniqueImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in nil })

        sut.didFinishLoadingImageData(with: Data(), for: image)

        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertNil(message?.image)
    }
    
    //MARK: -Helpers
    
    private func makeSUT(imageTransformer: @escaping (Data) -> Any? = { _ in nil }) -> (FeedImagePresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
        
        return (sut, view)
    }
    
    private class ViewSpy: FeedImageView {
        
        private(set) var messages: [FeedImageViewModel] = []
        
        func display(_ viewModel: FeedImageViewModel) {
            messages.append(viewModel)
        }
    }
}
