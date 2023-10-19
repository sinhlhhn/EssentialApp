//
//  FeedViewControllerTests.swift
//  FeedViewControllerTests
//
//  Created by Sam on 31/08/2023.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
import EssentialApp

class FeedUIIntegrationTests: XCTestCase {
    
    func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, feedTitle)
    }
    
    func test_imageSelection_notifiesHandler() {
        let image0 = makeImage()
        let image1 = makeImage()
        var selectedImages = [FeedImage]()
        let (sut, loader) = makeSUT(selection: { selectedImages.append($0) })
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0, image1], at: 0)
        
        sut.simulateTapFeedImage(at: 0)
        XCTAssertEqual(selectedImages, [image0])
        
        sut.simulateTapFeedImage(at: 1)
        XCTAssertEqual(selectedImages, [image0, image1])
    }
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        loader.completeLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }
    
    func test_loadMoreActions_requestMoreFromLoader() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeLoading(at: 0)
        
        XCTAssertEqual(loader.loadMoreCallCount, 0, "Expected no requests before until load more action")
        
        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(loader.loadMoreCallCount, 1, "Expected load more request")
        
        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(loader.loadMoreCallCount, 1, "Expected no request while loading more")
        
        loader.completeLoadMore(isLastPage: false, at: 0)
        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(loader.loadMoreCallCount, 2, "Expected request after load more with more pages")
        
        loader.completeLoadMoreWithError(at: 1)
        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(loader.loadMoreCallCount, 3, "Expected request after loading more failure")
        
        loader.completeLoadMore(isLastPage: true, at: 2)
        XCTAssertEqual(loader.loadMoreCallCount, 3, "Expected no request after loading all pages")
    }
    
    func test_loadMoreIndicator_isVisibleWhileLoadMore() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertFalse(sut.isShowingLoadMoreIndicator, "Expected no loading indicator once view is loaded")
        
        loader.completeLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadMoreIndicator, "Expected no load more indicator once loading completes successfully")
        
        sut.simulateLoadMoreFeedAction()
        XCTAssertTrue(sut.isShowingLoadMoreIndicator, "Expected load more indicator on load more action")
        
        loader.completeLoadMore(at: 0)
        XCTAssertFalse(sut.isShowingLoadMoreIndicator, "Expected no load more indicator on load more completes successfully")
        
        sut.simulateLoadMoreFeedAction()
        XCTAssertTrue(sut.isShowingLoadMoreIndicator, "Expected loading indicator on second load more action")
        
        loader.completeLoadMoreWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadMoreIndicator, "Expected no loading indicator on load more completes with error")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "any description", location: "any location")
        let image1 = makeImage(description: nil, location: "any location")
        let image2 = makeImage(description: "any description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateLoadMoreFeedAction()
        loader.completeLoadMore(with: [image0, image1, image2], at: 0)
        assertThat(sut, isRendering: [image0, image1, image2])
        
        sut.simulateUserInitiatedReload()
        loader.completeLoading(with: [image0, image1, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image3])
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterLoadedNonEmptyFeed() {
        let image0 = makeImage()
        let image1 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateLoadMoreFeedAction()
        loader.completeLoadMore(with: [image0, image1], at: 0)
        assertThat(sut, isRendering: [image0, image1])
        
        sut.simulateUserInitiatedReload()
        loader.completeLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentStateOnError() {
        let image = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image], at: 0)
        
        sut.simulateUserInitiatedReload()
        loader.completeLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image])
        
        sut.simulateLoadMoreFeedAction()
        loader.completeLoadMoreWithError(at: 0)
        assertThat(sut, isRendering: [image])
    }
    
    func test_loadFeedCompletion_dispatchFromBackgroundThreadToMainThread() {
        let image = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "wait for completion")
        DispatchQueue.global().async {
            loader.completeLoading(with: [image], at: 0)
            exp.fulfill()
        }
        
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_loadMoreCompletion_dispatchFromBackgroundThreadToMainThread() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(at: 0)
        sut.simulateLoadMoreFeedAction()
        
        let exp = expectation(description: "wait for completion")
        DispatchQueue.global().async {
            loader.completeLoadMore(at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_loadImageCompletion_dispatchFromBackgroundThreadToMainThread() {
        let image = makeImage()
        let imageData = anyImageData()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image], at: 0)
        sut.simulateFeedImageViewVisible(at: 0)
        
        let exp = expectation(description: "wait for completion")
        DispatchQueue.global().async {
            loader.completeLoadingImage(with: imageData, at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_errorView_doesNotRenderErrorOnLoadFeed() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_errorView_rendersErrorOnLoadError() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoadingWithError(at: 0)
        
        XCTAssertEqual(sut.errorMessage, loadError)
    }
    
    func test_errorView_hideErrorOnReload() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoadingWithError(at: 0)
        sut.simulateUserInitiatedReload()
        
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_errorView_hideErrorOnTapError() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoadingWithError(at: 0)
        sut.simulateTapErrorMessage()
        
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    // MARK: - Image View Tests
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let image = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image, image1], at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [])
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image.imageURL])
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image.imageURL, image1.imageURL])
    }
    
    func test_feedImageView_cancelsImageURLWhenOutOfScreen() {
        let image = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image, image1], at: 0)
        XCTAssertEqual(loader.canceledImageURLs, [])
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.canceledImageURLs, [image.imageURL])
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.canceledImageURLs, [image.imageURL, image1.imageURL])
    }
    
    func test_feedImageView_showsLoadingIndicatorWhileLoadingImage() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [makeImage(), makeImage()], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for the first view while loading first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for the second view while loading second image")
        
        loader.completeLoadingImage(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for the first view once the first image loading complete successfully")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change for the second view once first image loading complete successfully")
        
        loader.completeLoadingImageWithError(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view once second image loading completes with error")
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [makeImage(), makeImage()], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for the first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for the second view while loading second image")
        
        let image0 = UIImage.make(with: .red).pngData()!
        loader.completeLoadingImage(with: image0,at: 0)
        XCTAssertEqual(view0?.renderedImage, image0, "Expected image for the first view once the first image loading complete successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for the second view once first image loading complete successfully")
        
        loader.completeLoadingImageWithError(at: 1)
        XCTAssertEqual(view0?.renderedImage, image0, "Expected no image state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view once second image loading completes with error")
    }
    
    func test_feedImageView_showsButtonRetryOnImageURLLoadError() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [makeImage(), makeImage()], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for the first view while loading first image")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for the second view while loading second image")
        
        let image0 = UIImage.make(with: .red).pngData()!
        loader.completeLoadingImage(with: image0, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for the first view once loading first image complete successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for the second view once loading first image complete successfully")
        
        loader.completeLoadingImageWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action state change for the first view once loading second image complete with error")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected retry action for the second view once loading second image complete with error")
    }
    
    func test_feedImageView_showsButtonRetryOnImageURLInvalidDataError() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [makeImage(), makeImage()], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for the first view while loading first image")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for the second view while loading second image")
        
        let image0 = UIImage.make(with: .red).pngData()!
        loader.completeLoadingImage(with: image0, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for the first view once loading first image complete successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for the second view once loading first image complete successfully")
        
        let invalidData = Data()
        loader.completeLoadingImage(with: invalidData, at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action state change for the first view once loading second image complete with invalid data")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected retry action for the second view once loading second image complete with invalid data")
    }
    
    func test_feedImageViewRetryAction_retriesImageLoad() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0, image1], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL], "Expected two image url request for the two visible view")
        
        loader.completeLoadingImageWithError(at: 0)
        loader.completeLoadingImageWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL], "Expected only two image url request before retry action")
        
        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL, image0.imageURL], "Expected third image url request after the first view retry action")
        
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL, image0.imageURL, image1.imageURL], "Expected fourth image url request after the second view retry action")
    }
    
    func test_feedImageView_preloadsImageWhenImageViewNearVisible() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image url request for the when the images view do not near visible")
        
        sut.simulateFeedImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL], "Expected one image url request for the first view near visible")
        
        sut.simulateFeedImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL], "Expected two image url request for the two near visible")
        
    }
    
    func test_feedImageView_cancelsImageWhenImageViewNotNearVisible() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.canceledImageURLs, [], "Expected no cancelled image URL requests until image is not near visible")
        
        sut.simulateFeedImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.canceledImageURLs, [image0.imageURL], "Expected first cancelled image URL request once first image is not near visible anymore")
        
        sut.simulateFeedImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.canceledImageURLs, [image0.imageURL, image1.imageURL], "Expected second cancelled image URL request once second image is not near visible anymore")
        
    }
    
    func test_feedImageView_doesNotLoadImageWhenImageViewNotVisible() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [makeImage()], at: 0)
        let view = sut.simulateFeedImageViewNotVisible(at: 0)
        loader.completeLoadingImage(with: anyImageData(), at: 0)
        
        XCTAssertNil(view?.renderedImage, "Expected nil got \(String(describing: view?.renderedImage)) instead")
    }
    
    func test_feedImageView_doesNotShowDataFromPreviousRequestWhenCellIsReused() throws {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [makeImage(), makeImage()], at: 0)
        
        let view0 = try XCTUnwrap(sut.simulateFeedImageViewVisible(at: 0))
        view0.prepareForReuse()
        
        let imageData0 = UIImage.make(with: .red).pngData()!
        loader.completeLoadingImage(with: imageData0, at: 0)
        
        XCTAssertEqual(view0.renderedImage, .none, "Expected no image state change for reused view once image loading completes successfully")
    }
    
    //MARK: -Helpers
    
    private func makeSUT(
        selection: @escaping (FeedImage) -> Void = { _ in },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (ListViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(
            loader: loader.loadPublisher,
            imageLoader: loader.loadImageDataPublisher,
            selection: selection)
        
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(loader, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url")!) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private func anyImageData() -> Data {
        UIImage.make(with: .red).pngData()!
    }
}
