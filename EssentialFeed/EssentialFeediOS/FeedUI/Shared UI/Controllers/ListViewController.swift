//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Sam on 04/09/2023.
//

import UIKit
import EssentialFeed

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
    public private(set) var errorView = ErrorView()
    
    public var onRefresh: (() -> ())?
    
    private lazy var dataSource = UITableViewDiffableDataSource<Int, CellController>(tableView: tableView) { tableView, indexPath, controller in
        controller.datasource.tableView(tableView, cellForRowAt: indexPath)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        refresh()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.sizeTableHeaderToFit()
    }
    
    @IBAction private func refresh() {
        onRefresh?()
    }
    
    private func configureTableView() {
        dataSource.defaultRowAnimation = .fade
        tableView.tableHeaderView = errorView.makeContainer()
        
        errorView.onHide = { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.sizeTableHeaderToFit()
            self?.tableView.endUpdates()
        }
    }
    
    public func display(_ tableModel: [CellController]...) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        tableModel.enumerated().forEach { section, tableModel in
            snapshot.appendSections([section])
            snapshot.appendItems(tableModel, toSection: section)
        }
        dataSource.apply(snapshot)
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.message
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = cellController(forRowAt: indexPath)?.delegate
        dl?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = cellController(forRowAt: indexPath)?.delegate
        dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(forRowAt: indexPath)?.prefetching
            dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(forRowAt: indexPath)?.prefetching
            dsp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dl = cellController(forRowAt: indexPath)?.delegate
        dl?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> CellController? {
        return dataSource.itemIdentifier(for: indexPath)
    }
}
