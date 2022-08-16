//
//  FeedPresenter.swift
//  EssentialiOS
//
//  Created by lakshman-7016 on 16/08/22.
//

import Foundation
import Essential

struct FeedLoadingViewModel {
    var isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    var feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
    var feedView: FeedView?
    var loadingView: FeedLoadingView?
    
    func didStartLoadingFeed() {
        self.loadingView?.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        self.feedView?.display(FeedViewModel(feed: feed))
        self.loadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        self.loadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
}

