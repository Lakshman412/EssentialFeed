//
//  FeedLoader.swift
//  Essential
//
//  Created by lakshman-7016 on 14/04/21.
//

import Foundation

public enum LoadFeedResult {
	case success([FeedImage])
	case failure(Error)
}

public protocol FeedLoader {
	func load(completion: @escaping (LoadFeedResult) -> Void)
}
