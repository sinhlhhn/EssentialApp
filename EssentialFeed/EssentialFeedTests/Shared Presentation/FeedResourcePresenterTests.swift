//
//  FeedResourcePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 03/10/2023.
//

import XCTest
import EssentialFeed

final class FeedResourcePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessage() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    func test_didStartLoading_displaysNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoading()
        
        XCTAssertEqual(view.messages, [.display(errorMessage: .none), .display(isLoading: true)])
    }
    
    func test_didFinishLoadingResource_displaysResourceAndStopLoading() {
        let resource = "resource"
        let (sut, view) = makeSUT(mapper: { result in
            result + " view models"
        })
        
        sut.didFinishLoading(with: resource)
        
        XCTAssertEqual(view.messages, [
            .display(resource: "resource view models"),
            .display(isLoading: false)])
    }
    
    func test_didFinishLoadingWithError_displayLocalizedErrorAndStopLoading() {
        let error = anyNSError()
        let (sut, view) = makeSUT()
        
        sut.didFinishLoading(with: error)
        
        XCTAssertEqual(view.messages, [.display(errorMessage: localized("GENERIC_CONNECTION_ERROR")), .display(isLoading: false)])
    }
    
    func test_didFinishLoadingWithMapperError_displaysLocalizedErrorAndStopLoading() {
        let resource = "resource"
        let (sut, view) = makeSUT(mapper: { result in
            throw anyNSError()
        })
        
        sut.didFinishLoading(with: resource)
        
        XCTAssertEqual(view.messages, [
            .display(errorMessage: localized("GENERIC_CONNECTION_ERROR")),
            .display(isLoading: false)])
    }
    
    //MARK: -Helpers
    
    private typealias SUT = LoadResourcePresenter<String, ViewSpy>
    
    private func makeSUT(mapper: @escaping SUT.Mapper = { _ in "default"}) -> (SUT, ViewSpy) {
        let view = ViewSpy()
        let sut = SUT(loadingView: view, resourceView: view, errorView: view, mapper: mapper)
        
        return (sut, view)
    }
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
            let table = "Shared"
            let bundle = Bundle(for: SUT.self)
            let value = bundle.localizedString(forKey: key, value: nil, table: table)
            if value == key {
                XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
            }
            return value
        }
    
    private class ViewSpy: ResourceLoadingView, ResourceView, ResourceErrorView {
        typealias ResourceViewModel = String
        
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(resource: String)
        }
        
        private(set) var messages: Set<Message> = []
        
        func display(_ viewModel: ResourceErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: ResourceLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: String) {
            messages.insert(.display(resource: viewModel))
        }
    }
}
