//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Sam on 08/09/2023.
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    private let loadFeed: (() -> ())
    private(set) lazy var view: UIRefreshControl = loadView()

    init(loadFeed: @escaping (() -> ())) {
        self.loadFeed = loadFeed
    }

    @objc func refresh() {
        loadFeed()
    }

    func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        return view
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
}
