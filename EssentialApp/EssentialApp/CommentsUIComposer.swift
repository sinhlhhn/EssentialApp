//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by Sam on 16/10/2023.
//

import Foundation
import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class CommentsUIComposer {
    private init() {}
    
    private typealias CommentsPresentationAdapter = LoadResourcePresentationAdapter<[ImageComment], CommentsViewAdapter>
    
    public static func commentsComposedWith(loader: @escaping () -> AnyPublisher<[ImageComment], Error>) -> ListViewController {
        
        let adapterComposer = CommentsPresentationAdapter(
            loader: loader)
        
        let commentsViewController = CommentsUIComposer.makeWith(title: ImageCommentsPresenter.title, onRefresh: adapterComposer.loadResource)
        commentsViewController.onRefresh = adapterComposer.loadResource
        
        adapterComposer.loadPresenter = LoadResourcePresenter(
            loadingView: WeakRefVirtualProxy(commentsViewController),
            resourceView:
                CommentsViewAdapter(controller: commentsViewController),
            errorView: WeakRefVirtualProxy(commentsViewController),
            mapper: { ImageCommentsPresenter.map($0) })
        
        return commentsViewController
    }
    
    private static func makeWith(title: String, onRefresh: (() -> ())?) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let sb = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = sb.instantiateViewController(identifier: "ImageCommentsViewController") as! ListViewController
        
        controller.title = title
        
        return controller
    }
}

public class CommentsViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    
    init(controller: ListViewController) {
        self.controller = controller
    }
    
    public func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(viewModel.comments.map { viewModel in
           CellController(id: viewModel, UITableViewController())
        })
    }
}
