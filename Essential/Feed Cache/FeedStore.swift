//
//  FeedStore.swift
//  Essential
//
//  Created by lakshman-7016 on 20/06/21.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timeStamp: Date)

public protocol FeedStore {
	typealias DeletionResult = Result<Void, Error>
	typealias DeletionCompletion = (DeletionResult) -> Void

	typealias InsertionResult = Result<Void, Error>
	typealias InsertionCompletion = (InsertionResult) -> Void

	typealias RetrievalResult = Swift.Result<CachedFeed?, Error>
	typealias RetrievalCompletion = (RetrievalResult) -> Void

	func deleteCachedFeed(completion: @escaping DeletionCompletion)
	func insertFeed(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion)
	func retrieve(completion: @escaping RetrievalCompletion)
}
