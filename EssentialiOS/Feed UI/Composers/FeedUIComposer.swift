//
//  FeedUIComposer.swift
//  EssentialiOS
//
//  Created by lakshman-7016 on 14/08/22.
//

import Essential
import UIKit

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refeshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedController = FeedViewController(refreshController: refeshController)
        feedViewModel.onFeedLoad = adaptFeedToCellController(forwardTo: feedController, imageLoader: imageLoader)
        return feedController
    }
    
    private static func adaptFeedToCellController(forwardTo controller: FeedViewController, imageLoader: FeedImageDataLoader) -> (([FeedImage]) -> Void) {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellController(viewModel: FeedImageViewModel<UIImage>(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init))
            }
        }
    }
}
