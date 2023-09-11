//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Sam on 08/09/2023.
//

import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

final class FeedImageCellController: FeedImageView {
    private let cell = FeedImageCell()
    private let delegate: FeedImageCellControllerDelegate
    
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        delegate.didRequestImage()
        return cell
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancel() {
        delegate.didCancelImageRequest()
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
        
        cell.onRetry = delegate.didRequestImage
    }
}
