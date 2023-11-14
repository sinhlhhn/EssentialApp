//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Sam on 03/10/2023.
//

import Foundation

public protocol ResourceView {
    associatedtype ResourceViewModel
    func display(_ viewModel: ResourceViewModel)
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
    public typealias Mapper = (Resource) throws -> View.ResourceViewModel
    
    private let loadingView: ResourceLoadingView
    private let resourceView: View
    private let errorView: ResourceErrorView
    private let mapper: Mapper
    
    public init(loadingView: ResourceLoadingView, resourceView: View, errorView: ResourceErrorView, mapper: @escaping Mapper) {
        self.loadingView = loadingView
        self.resourceView = resourceView
        self.errorView = errorView
        self.mapper = mapper
    }
    
    public init(loadingView: ResourceLoadingView, resourceView: View, errorView: ResourceErrorView) where Resource == View.ResourceViewModel {
        self.loadingView = loadingView
        self.resourceView = resourceView
        self.errorView = errorView
        self.mapper = { $0 }
    }
    
    private var loadError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR",tableName: "Shared", bundle: Bundle.module, comment: "Error message display when we can't get the resource from server")
    }
    
    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with resource: Resource) {
        do {
            resourceView.display(try mapper(resource))
            loadingView.display(ResourceLoadingViewModel(isLoading: false))
        } catch {
            didFinishLoading(with: error)
        }
    }
    
    public func didFinishLoading(with error: Error) {
        errorView.display(.error(message: loadError))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
}
