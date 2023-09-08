//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Sam on 08/09/2023.
//

import UIKit
import EssentialFeed

final class FeedRefreshViewController: NSObject {
    private var feedLoader: FeedLoader?
    
    private(set) lazy var view: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    init(feedLoader: FeedLoader?) {
        self.feedLoader = feedLoader
    }
    
    var onRefresh: (([FeedImage]) -> ())?
    
    @objc func refresh() {
        view.beginRefreshing()
        feedLoader?.load { [weak self] result in
            if let items = try? result.get() {
                self?.onRefresh?(items)
            }
            self?.view.endRefreshing()
        }
    }
}
