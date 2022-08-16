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
        let presenter = FeedPresenter(feedLoader: feedLoader)
        let refeshController = FeedRefreshViewController(presenter: presenter)
        let feedController = FeedViewController(refreshController: refeshController)
        presenter.loadingView = WeakRefVirtualProxy(refeshController)
        presenter.feedView = FeedViewAdapter(controller: feedController, imageLoader: imageLoader)
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

private final class WeakRefVirtualProxy<T: AnyObject> {
    weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        self.object?.display(viewModel)
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private var imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            FeedImageCellController(viewModel: FeedImageViewModel<UIImage>(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init))
        }
    }
}
