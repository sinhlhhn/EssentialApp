//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by Sam on 11/09/2023.
//

import Foundation
import EssentialFeed

struct FeedImageViewModel<Image> {
    let image: Image?
    let shouldRetry: Bool
    let isLoading: Bool
    let location: String?
    let description: String?
    
    var hasLocation: Bool {
        return location != nil
    }
    
    var hasDescription: Bool {
        description != nil
    }
}

protocol FeedImageView {
    associatedtype Image
    func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image>: FeedImagePresentInput where View.Image == Image {
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
    
    var view: View!
    
    func didPreLoadData() {
        task = imageLoader?.loadImageData(from: model.imageURL) { _ in }
    }
    
    func didCancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
    
    func didLoadImageData(){
        view.display(FeedImageViewModel(image: nil, shouldRetry: false, isLoading: true, location: model.location, description: model.description))
        
        task = imageLoader?.loadImageData(from: model.imageURL) { [weak self] result in
            self?.handle(result)
        }
    }
    
    func handle(_ result: Result<Data, Error>) {
        switch result {
        case let .success(data):
            if let image = self.imageTransformer(data) {
                view.display(FeedImageViewModel(image: image, shouldRetry: false, isLoading: false, location: model.location, description: model.description))
            } else {
                view.display(FeedImageViewModel(image: nil, shouldRetry: true, isLoading: false, location: model.location, description: model.description))
            }
        case .failure(_):
            view.display(FeedImageViewModel(image: nil, shouldRetry: true, isLoading: false, location: model.location, description: model.description))
        }
    }
}
