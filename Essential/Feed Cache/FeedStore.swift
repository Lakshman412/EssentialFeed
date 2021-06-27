//
//  FeedStore.swift
//  Essential
//
//  Created by lakshman-7016 on 20/06/21.
//

import Foundation

public enum RetrieveCachedFeedResult {
	case empty
	case found(feed: [LocalFeedImage], timeStamp: Date)
	case failure(Error)
}

public protocol FeedStore {
	typealias DeletionCompletion = (Error?) -> Void
	typealias InsertionCompletion = (Error?) -> Void
	typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void

	func deleteCachedFeed(completion: @escaping DeletionCompletion)
	func insertFeed(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion)
	func retrieve(completion: @escaping RetrievalCompletion)
}
