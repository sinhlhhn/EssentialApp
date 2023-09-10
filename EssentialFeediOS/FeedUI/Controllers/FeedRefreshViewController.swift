//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Sam on 08/09/2023.
//

import UIKit

final class FeedRefreshViewController: NSObject {
    private var viewModel: FeedViewModel

    private(set) lazy var view: UIRefreshControl = bind(to: UIRefreshControl())

    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }

    @objc func refresh() {
        viewModel.loadFeed()
    }

    func bind(to view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onLoadingStateChange = { [weak self] isLoading in
            if isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
        }

        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        return view
    }
}
