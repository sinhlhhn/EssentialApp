//
//  ListViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Sam on 08/09/2023.
//

import UIKit
import EssentialFeediOS

extension ListViewController {
    public override func loadViewIfNeeded() {
        super.loadViewIfNeeded()
        
        tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var errorMessage: String? {
        errorView.message
    }
    
    func simulateTapErrorMessage() {
        errorView.errorButton.simulateTap()
    }
    
    func numberOfRow(in section: Int) -> Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }
    
    func cell(row: Int, section: Int) -> UITableViewCell? {
        guard numberOfRow(in: section) > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: section)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}

extension ListViewController {
    
    @discardableResult
    func simulateFeedImageViewVisible(at row: Int) -> FeedImageCell? {
        return feedImageView(at: row) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        
        return view
    }
    
    func simulateFeedImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    
    func numberOfRenderedFeedImageViews() -> Int {
        numberOfRow(in: feedImageSection)
    }
    
    private var feedImageSection: Int { 0 }
    private var loadMoreSection: Int { 1 }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        cell(row: row, section: feedImageSection)
    }
    
    func renderedImage(at index: Int) -> Data? {
        simulateFeedImageViewVisible(at: index)?.renderedImage
    }
    
    func simulateTapFeedImage(at row: Int) {
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didSelectRowAt: index)
    }
    
    func simulateLoadMoreFeedAction() {
        guard let view = loadMoreCell() else {
            return
        }
        
        let delegate = tableView.delegate
        let index = IndexPath(row: 0, section: loadMoreSection)
        delegate?.tableView?(tableView, willDisplay: view, forRowAt: index)
    }
    
    var isShowingLoadMoreIndicator: Bool {
        return loadMoreCell()?.isLoading == true
    }
    
    private func loadMoreCell() -> LoadMoreCell? {
        return cell(row: 0, section: loadMoreSection) as? LoadMoreCell
    }
    
    var loadMoreErrorMessage: String? {
        loadMoreCell()?.message
    }
}

extension ListViewController {
    private var commentsSection: Int {
        return 0
    }
    
    func numberOfRenderedCommentsViews() -> Int {
        tableView.numberOfSections == 0 ? 0 :  tableView.numberOfRows(inSection: commentsSection)
    }
    
    private func commentsView(at row: Int) -> ImageCommentCell? {
        return cell(row: row, section: feedImageSection) as? ImageCommentCell
    }
    
    func commentMessage(at row: Int) -> String? {
        commentsView(at: row)?.messageLabel.text
    }
    
    func commentUsername(at row: Int) -> String? {
        commentsView(at: row)?.usernameLabel.text
    }
    
    func commentDate(at row: Int) -> String? {
        commentsView(at: row)?.dateLabel.text
    }
    
    func numberOfRenderedComments() -> Int {
        numberOfRow(in: commentsSection)
    }
}
