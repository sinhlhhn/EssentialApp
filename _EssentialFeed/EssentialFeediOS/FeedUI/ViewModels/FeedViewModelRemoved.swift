//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Sam on 10/09/2023.
//

import Foundation
import EssentialFeed

//final class FeedViewModelRemoved {
//    typealias Observer<T> = (T) -> ()
//    private var feedLoader: FeedLoader
//
//    init(feedLoader: FeedLoader) {
//        self.feedLoader = feedLoader
//    }
//
//    var onLoadingStateChange: Observer<Bool>?
//    var onFeedLoad: Observer<[FeedImage]>?
//
//    func loadFeed() {
//        onLoadingStateChange?(true)
//        feedLoader.load { [weak self] feed in
//            if let items = try? feed.get() {
//                self?.onFeedLoad?(items)
//            }
//            self?.onLoadingStateChange?(false)
//        }
//    }
//}
