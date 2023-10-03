//
//  WeakRefVirtualProxy.swift
//  EssentialFeediOS
//
//  Created by Sam on 13/09/2023.
//

import Foundation
import EssentialFeed

class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ weakRef: T) {
        self.object = weakRef
    }
}

extension WeakRefVirtualProxy: ResourceLoadingView where T: ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView {
    typealias Image = T.Image
    
    func display(_ viewModel: FeedImageViewModel<T.Image>) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ResourceErrorView where T: ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel) {
        object?.display(viewModel)
    }
}
