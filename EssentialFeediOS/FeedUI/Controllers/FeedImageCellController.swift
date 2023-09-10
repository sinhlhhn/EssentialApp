//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Sam on 08/09/2023.
//

import UIKit

final class FeedImageCellController {
    private let viewModel: FeedImageViewModel<UIImage>
    
    init(viewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func view(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = bind(to: FeedImageCell())
        viewModel.load()
        
        return cell
    }
    
    func bind(to cell: FeedImageCell) -> FeedImageCell {
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.isHidden = !viewModel.hasDescription
        cell.descriptionLabel.text = viewModel.description
        cell.feedImage.image = nil
        cell.onRetry = viewModel.load
        
        viewModel.onImageLoad = { [weak cell] image in
            cell?.feedImage.image = image
        }
        
        viewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
            cell?.retryButton.isHidden = !shouldRetry
        }
        
        viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
            cell?.feedImageContainer.isShimmering = isLoading
        }
        
        return cell
    }
    
    func preload() {
        viewModel.preload()
    }
    
    func cancel() {
        viewModel.cancel()
    }
}
