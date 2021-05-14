//
//  FeedLoader.swift
//  Essential
//
//  Created by lakshman-7016 on 14/04/21.
//

import Foundation

public enum LoadFeedResult<Error: Swift.Error> {
	case success([FeedItem])
	case failure(Error)
}

extension LoadFeedResult: Equatable where Error: Equatable {}

protocol FeedLoader {
	associatedtype Error: Swift.Error

	func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
