//
//  FeedStore.swift
//  Essential
//
//  Created by lakshman-7016 on 20/06/21.
//

import Foundation

public protocol FeedStore {
	typealias DeletionCompletion = (Error?) -> Void
	typealias InsertionCompletion = (Error?) -> Void
	typealias RetrievalCompletion = (Error?) -> Void

	func deleteCachedFeed(completion: @escaping DeletionCompletion)
	func insertFeed(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion)
	func retrieve(completion: @escaping RetrievalCompletion)
}
