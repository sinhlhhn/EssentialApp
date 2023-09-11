//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Sam on 08/09/2023.
//

import UIKit

final class FeedImageCellController: FeedImageView {
    let presenter: FeedImagePresenter<FeedImageCellController, UIImage>
    private let cell = FeedImageCell()
    
    init(presenter: FeedImagePresenter<FeedImageCellController, UIImage>) {
        self.presenter = presenter
    }
    
    func view(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        presenter.loadImageData()
        
        return cell
    }
    
    func preload() {
        presenter.preload()
    }
    
    func cancel() {
        presenter.cancelImageDataLoad()
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
        
        cell.onRetry = presenter.loadImageData
    }
}
