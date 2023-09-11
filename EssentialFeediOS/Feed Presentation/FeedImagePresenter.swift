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

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    var imageTransformer: (Data) -> Image?
    var view: View
    
    init(view: View, imageTransfer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransfer
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModel(image: nil, shouldRetry: false, isLoading: true, location: model.location, description: model.description))
    }
    
    private struct InvalidImageDataError: Error {}
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage){
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        
        view.display(FeedImageViewModel(image: image, shouldRetry: false, isLoading: false, location: model.location, description: model.description))
    }
    
    func didFinishLoadingImageData(with: Error, for model: FeedImage) {
        view.display(FeedImageViewModel(image: nil, shouldRetry: true, isLoading: false, location: model.location, description: model.description))
    }
}
