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
        let refeshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedController = FeedViewController(refreshController: refeshController)
        refeshController.onRefresh = adaptFeedToCellController(forwardTo: feedController, imageLoader: imageLoader)
        return feedController
    }
    
    private static func adaptFeedToCellController(forwardTo controller: FeedViewController, imageLoader: FeedImageDataLoader) -> (([FeedImage]) -> Void) {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellController(model: model, imageLoader: imageLoader)
            }
        }
    }
}
