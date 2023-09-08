//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Sam on 04/09/2023.
//

import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var imageLoader: FeedImageDataLoader?
    private var tableModel = [FeedImage]() {
        didSet { tableView.reloadData() }
    }
    
    private var cellControllers = [IndexPath : FeedImageCellController]()
    private var refreshController: FeedRefreshViewController?
    
    public convenience init(loader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.imageLoader = imageLoader
        self.refreshController = FeedRefreshViewController(feedLoader: loader)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        
        refreshControl = refreshController?.view
        refreshController?.onRefresh = { [weak self] images in
            self?.tableModel = images
        }
        refreshController?.refresh()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view(cellForRowAt: indexPath)
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
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        let cellModel = tableModel[indexPath.row]
        let cellController = FeedImageCellController(model: cellModel, imageLoader: imageLoader)
        cellControllers[indexPath] = cellController
        
        return cellController
    }
    
    private func cancelTask(forRowAt indexPath: IndexPath) {
        cellControllers[indexPath] = nil
    }
    
    private func startTask(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).preload()
    }
}
