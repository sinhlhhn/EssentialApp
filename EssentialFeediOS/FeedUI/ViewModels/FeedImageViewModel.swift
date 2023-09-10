//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Sam on 10/09/2023.
//

import Foundation
import EssentialFeed

final class FeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> ()
    
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader?
    private var task: FeedImageDataLoaderTask?
    var imageTransformer: (Data) -> Image?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader?, task: FeedImageDataLoaderTask? = nil, imageTransfer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.task = task
        self.imageTransformer = imageTransfer
    }
    
    var onImageLoad: Observer<Image>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    var onImageLoadingStateChange: Observer<Bool>?
    
    
    var location: String? {
        return model.location
    }
    
    var hasLocation: Bool {
        return location != nil
    }
    
    var description: String? {
        return model.description
    }
    
    var hasDescription: Bool {
        description != nil
    }
    
    var imageURL: URL {
        return model.imageURL
    }
    
    func preload() {
        task = imageLoader?.loadImageData(from: model.imageURL) { _ in }
    }
    
    func cancel() {
        task?.cancel()
        task = nil
    }
    
    func load(){
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        
        task = imageLoader?.loadImageData(from: model.imageURL) { [weak self] result in
            switch result {
            case let .success(data):
                if let image = self?.imageTransformer(data) {
                    self?.onImageLoad?(image)
                } else {
                    self?.onShouldRetryImageLoadStateChange?(true)
                }
            case .failure(_):
                self?.onShouldRetryImageLoadStateChange?(true)
            }
            
            self?.onImageLoadingStateChange?(false)
        }
        
    }
}
