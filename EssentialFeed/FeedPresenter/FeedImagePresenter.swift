//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Sam on 14/09/2023.
//

import Foundation

public protocol FeedImageView {
    associatedtype Image
    func display(_ viewModel: FeedImageViewModel<Image>)
}

public final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private var imageTransformer: (Data) -> Image?
    private var view: View
    
    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    private struct InvalidImageDataError: Error {}
    
    public func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModel(image: nil, shouldRetry: false, isLoading: true, location: model.location, description: model.description))
    }
    
    public func didFinishLoadingImageData(with: Error, for model: FeedImage) {
        view.display(FeedImageViewModel(image: nil, shouldRetry: true, isLoading: false, location: model.location, description: model.description))
    }
    
    public func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        
        view.display(FeedImageViewModel(image: image, shouldRetry: false, isLoading: false, location: model.location, description: model.description))
    }
}
