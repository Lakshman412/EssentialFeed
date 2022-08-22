//
//  FeedImageViewModel.swift
//  EssentialiOS
//
//  Created by lakshman-7016 on 22/08/22.
//

struct FeedImageViewModel<Image> {
    var description: String?
    var location: String?
    var image: Image?
    var isLoading: Bool
    var shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}
