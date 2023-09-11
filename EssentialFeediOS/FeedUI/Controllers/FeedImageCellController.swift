//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Sam on 08/09/2023.
//

import UIKit

protocol FeedImagePresentInput {
    func didLoadImageData()
    func didPreLoadData()
    func didCancelImageDataLoad()
}

final class FeedImageCellController: FeedImageView {
    let input: FeedImagePresentInput
    private let cell = FeedImageCell()
    
    init(input: FeedImagePresentInput) {
        self.input = input
    }
    
    func view(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        input.didLoadImageData()
        return cell
    }
    
    func preload() {
        input.didPreLoadData()
    }
    
    func cancel() {
        input.didCancelImageDataLoad()
    }
    
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.isHidden = !viewModel.hasDescription
        cell.descriptionLabel.text = viewModel.description
        cell.feedImage.image = nil
        
        cell.feedImage.image = viewModel.image
        cell.feedImageContainer.isShimmering = viewModel.isLoading
        cell.retryButton.isHidden = !viewModel.shouldRetry
        
        cell.onRetry = input.didLoadImageData
    }
}
