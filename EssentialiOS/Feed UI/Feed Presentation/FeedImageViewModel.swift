//
//  FeedImageViewModel.swift
//  EssentialiOS
//
//  Created by lakshman-7016 on 15/08/22.
//

import Foundation
import Essential

final class FeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    
    private var imageTransformer: (Data) -> Image?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
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
    
    var onImageLoad: Observer<Image>?
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
        if let image = (try? result.get()).flatMap(self.imageTransformer) {
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
