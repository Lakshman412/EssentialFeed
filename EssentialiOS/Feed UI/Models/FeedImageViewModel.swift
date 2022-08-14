//
//  FeedImageViewModel.swift
//  EssentialiOS
//
//  Created by lakshman-7016 on 15/08/22.
//

import Foundation
import Essential
import UIKit

final class FeedImageViewModel {
    typealias Observer<T> = (T) -> Void
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    var hasLocation: Bool {
        self.model.location != nil
    }
    
    var location: String? {
        self.model.location
    }
    
    var description: String? {
        self.model.description
    }
    
    var onImageLoad: Observer<UIImage>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        task = self.imageLoader.loadImageData(from: model.url) { [weak self] result in
            self?.handleResult(result)
        }
    }
    
    func handleResult(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(UIImage.init) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }
        onImageLoadingStateChange?(false)
    }
    
    func cancelImageDataLoad() {
        self.task?.cancel()
        self.task = nil
    }
}
