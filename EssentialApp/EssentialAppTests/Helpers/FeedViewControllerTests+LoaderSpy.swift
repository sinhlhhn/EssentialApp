//
//  FeedViewControllerTests+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by Sam on 08/09/2023.
//

import Foundation
import EssentialFeediOS
import EssentialFeed
import Combine

extension FeedUIIntegrationTests {
    
    class LoaderSpy {
        
        //MARK: - FeedLoader
        
        private var feedRequests: [PassthroughSubject<Paginated<FeedImage>, Error>] = []
        
        func loadPublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
            let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
            feedRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        var loadFeedCallCount: Int {
            feedRequests.count
        }
        
        func completeLoading(with images: [FeedImage] = [], at index: Int) {
            feedRequests[index].send(Paginated<FeedImage>(items: images, loadMorePublisher: { [weak self] in
                let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
                self?.loadMoreRequests.append(publisher)
                return publisher.eraseToAnyPublisher()
            }))
            feedRequests[index].send(completion: .finished)
        }
        
        func completeLoadingWithError(at index: Int) {
            let error = NSError(domain: "", code: 1)
            feedRequests[index].send(completion: .failure(error))
        }
        
        // MARK: - FeedImageDataLoader
        
        private var imageRequests = [(url: URL, publisher: PassthroughSubject<Data, Error>)]()
        
        var loadedImageURLs: [URL] {
            return imageRequests.map { $0.url }
        }
        
        private(set) var canceledImageURLs = [URL]()
        
        func loadImageDataPublisher(from url: URL) -> AnyPublisher<Data, Error> {
            let publisher = PassthroughSubject<Data, Error>()
            imageRequests.append((url, publisher))
            return publisher.handleEvents(receiveCancel: { [weak self] in
                self?.canceledImageURLs.append(url)
            }).eraseToAnyPublisher()
        }
        
        func completeLoadingImage(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].publisher.send(imageData)
            imageRequests[index].publisher.send(completion: .finished)
        }
        
        func completeLoadingImageWithError(at index: Int = 0) {
            imageRequests[index].publisher.send(completion: .failure(anyNSError()))
        }
        
        
        //MARK: - LoadMoreFeedLoader
        
        private var loadMoreRequests: [PassthroughSubject<Paginated<FeedImage>, Error>] = []
        
        var loadMoreCallCount: Int {
            loadMoreRequests.count
        }
        
        func completeLoadMore(with images: [FeedImage] = [], isLastPage: Bool = false, at index: Int) {
            loadMoreRequests[index].send(Paginated<FeedImage>(items: images, loadMorePublisher: { [weak self] in
                let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
                self?.loadMoreRequests.append(publisher)
                return publisher.eraseToAnyPublisher()
            }))
        }
        
        func completeLoadMoreWithError(at index: Int) {
            let error = NSError(domain: "", code: 1)
            loadMoreRequests[index].send(completion: .failure(error))
        }
    }
}
