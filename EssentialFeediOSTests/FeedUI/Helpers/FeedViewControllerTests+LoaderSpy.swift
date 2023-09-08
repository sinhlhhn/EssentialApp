//
//  FeedViewControllerTests+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by Sam on 08/09/2023.
//

import Foundation
import EssentialFeediOS
import EssentialFeed

extension FeedViewControllerTests {
    
    class LoaderSpy: FeedLoader, FeedImageDataLoader {
        
        //MARK: - FeedLoader
        
        private var feedRequests: [(FeedLoader.Result) -> Void] = []
        
        var loadFeedCallCount: Int {
            feedRequests.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeLoading(with images: [FeedImage] = [], at index: Int) {
            feedRequests[index](.success(images))
        }
        
        func completeLoadingWithError(at index: Int) {
            let error = NSError(domain: "", code: 1)
            feedRequests[index](.failure(error))
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
