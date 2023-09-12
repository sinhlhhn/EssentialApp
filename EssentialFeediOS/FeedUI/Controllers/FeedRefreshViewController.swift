//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Sam on 08/09/2023.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    var delegate: FeedRefreshViewControllerDelegate?
    @IBOutlet private(set) var view: UIRefreshControl?

    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view?.beginRefreshing()
        } else {
            view?.endRefreshing()
        }
    }
}
