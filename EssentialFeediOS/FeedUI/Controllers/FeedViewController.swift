//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Sam on 04/09/2023.
//

import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var feedLoader: FeedLoader?
    private var imageLoader: FeedImageDataLoader?
    private var tableModel = [FeedImage]()
    private var cancelTasks = [IndexPath : FeedImageDataLoaderTask]()
    
    public convenience init(loader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.feedLoader = loader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        feedLoader?.load { [weak self] result in
            if let items = try? result.get() {
                self?.tableModel = items
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = cellModel.location == nil
        cell.locationLabel.text = cellModel.location
        cell.descriptionLabel.isHidden = cellModel.description == nil
        cell.descriptionLabel.text = cellModel.description
        cell.feedImage.image = nil
        cell.retryButton.isHidden = true
        cell.feedImageContainer.startShimmering()
        let loader = { [weak self, weak cell] in
            guard let self = self else {
                return
            }
            
            self.cancelTasks[indexPath] = self.imageLoader?.loadImageData(from: cellModel.imageURL) { result in
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
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        startTask(forRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(startTask)
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask)
    }
    
    private func cancelTask(forRowAt indexPath: IndexPath) {
        cancelTasks[indexPath]?.cancel()
        cancelTasks[indexPath] = nil
    }
    
    private func startTask(forRowAt indexPath: IndexPath) {
        let cellModel = tableModel[indexPath.row]
        cancelTasks[indexPath] = imageLoader?.loadImageData(from: cellModel.imageURL) { _ in }
    }
}
