//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Sam on 08/09/2023.
//

import UIKit

final class FeedImageCellController: FeedImageView {
    var presenter: FeedImagePresenter<FeedImageCellController, UIImage>!
    private let cell = FeedImageCell()
    
//    init(presenter: FeedImagePresenter<FeedImageCellController, UIImage>) {
//        self.presenter = presenter
//    }
    
    func view(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        loadView()
        presenter.loadImageData()
        
        return cell
    }
    
    func loadView() {
        cell.locationContainer.isHidden = !presenter.hasLocation
        cell.locationLabel.text = presenter.location
        cell.descriptionLabel.isHidden = !presenter.hasDescription
        cell.descriptionLabel.text = presenter.description
        cell.feedImage.image = nil
        cell.onRetry = presenter.loadImageData
    }
    
    func preload() {
        presenter.preload()
    }
    
    func cancel() {
        presenter.cancelImageDataLoad()
    }
    
    func display(image: UIImage) {
        cell.feedImage.image = image
    }
    
    func display(isLoading: Bool) {
        cell.feedImageContainer.isShimmering = isLoading
    }
    
    func displayRetry(shouldRetry: Bool) {
        cell.retryButton.isHidden = !shouldRetry
    }
}
