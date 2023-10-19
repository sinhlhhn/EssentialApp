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
    
    class LoaderSpy: FeedImageDataLoader {
        
        //MARK: - FeedLoader
        
        private var feedRequests: [PassthroughSubject<Paginated<FeedImage>, Error>] = []
        private(set) var loadMoreCallCount = 0
        
        func loadPublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
            let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
            feedRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        var loadFeedCallCount: Int {
            feedRequests.count
        }
        
        func completeLoading(with images: [FeedImage] = [], at index: Int) {
            feedRequests[index].send(Paginated<FeedImage>(items: images, loadMore: { [weak self] _ in
                self?.loadMoreCallCount += 1
            }))
        }
        
        func completeLoadingWithError(at index: Int) {
            let error = NSError(domain: "", code: 1)
            feedRequests[index].send(completion: .failure(error))
        }
        
        //MARK: - FeedImageDataLoader
        
        private struct CancelDataTaskSpy: FeedImageDataLoaderTask {

            let cancelCallback: () -> ()
            
            func cancel() {
                cancelCallback()
            }
        }
        
        private (set) var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> ())]()
        private (set) var canceledImageURLs = [URL]()
        
        var loadedImageURLs: [URL] {
            imageRequests.map { $0.url }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> ()) -> FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            return CancelDataTaskSpy { [weak self] in
                self?.canceledImageURLs.append(url)
            }
        }
        
        func completeLoadingImage(with data: Data = Data(), at index: Int) {
            imageRequests[index].completion(.success(data))
        }
        
        func completeLoadingImageWithError(at index: Int) {
            let error = NSError(domain: "", code: 0)
            imageRequests[index].completion(.failure(error))
        }
    }
}
