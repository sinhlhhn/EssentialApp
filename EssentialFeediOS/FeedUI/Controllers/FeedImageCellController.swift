//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Sam on 08/09/2023.
//

import UIKit
import EssentialFeed

final class FeedImageCellController {
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader?
    private var task: FeedImageDataLoaderTask?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader?) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = model.location == nil
        cell.locationLabel.text = model.location
        cell.descriptionLabel.isHidden = model.description == nil
        cell.descriptionLabel.text = model.description
        cell.feedImage.image = nil
        cell.retryButton.isHidden = true
        cell.feedImageContainer.startShimmering()
        let loader = { [weak self, weak cell] in
            guard let self = self else {
                return
            }
            
            self.task = self.imageLoader?.loadImageData(from: model.imageURL) { result in
                switch result {
                case let .success(data):
                    guard let image = UIImage(data: data) else {
                        cell?.retryButton.isHidden = false
                        break
                    }
                    cell?.feedImage.image = image
                case .failure(_):
                    cell?.retryButton.isHidden = false
                }
                
                cell?.feedImageContainer.stopShimmering()
            }
        }
        
        cell.onRetry = loader
        
        loader()
        
        return cell
    }
    
    func preload() {
        task = imageLoader?.loadImageData(from: model.imageURL) { _ in }
    }
    
    deinit {
        self.task?.cancel()
    }
}
