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
        refeshController.onRefresh = { [weak feedController] feed in
            feedController?.tableModel = feed.map {
                FeedImageCellController(model: $0, imageLoader: imageLoader)
            }
        }
        return feedController
    }
}
