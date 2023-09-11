//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by Sam on 11/09/2023.
//

import Foundation
import EssentialFeed

protocol FeedImageView {
    associatedtype Image
    func display(image: Image)
    func displayRetry(shouldRetry: Bool)
    func display(isLoading: Bool)
}

final class FeedImagePresenter<View: FeedImageView,Image> where View.Image == Image {
    typealias Observer<T> = (T) -> ()
    
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader?
    private var task: FeedImageDataLoaderTask?
    var imageTransformer: (Data) -> Image?
    
    init(view: View, model: FeedImage, imageLoader: FeedImageDataLoader?, task: FeedImageDataLoaderTask? = nil, imageTransfer: @escaping (Data) -> Image?) {
        self.view = view
        self.model = model
        self.imageLoader = imageLoader
        self.task = task
        self.imageTransformer = imageTransfer
    }
    
    private let view: View
    
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
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
    
    func loadImageData(){
        view.display(isLoading: true)
        view.displayRetry(shouldRetry: false)
        
        task = imageLoader?.loadImageData(from: model.imageURL) { [weak self] result in
            self?.handle(result)
        }
    }
    
    func handle(_ result: Result<Data, Error>) {
        switch result {
        case let .success(data):
            if let image = self.imageTransformer(data) {
                view.display(image: image)
            } else {
                view.displayRetry(shouldRetry: true)
            }
        case .failure(_):
            view.displayRetry(shouldRetry: true)
        }
        
        view.display(isLoading: false)
    }
}
