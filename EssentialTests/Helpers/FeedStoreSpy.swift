//
//  FeedStoreSpy.swift
//  EssentialTests
//
//  Created by lakshman-7016 on 23/06/21.
//

import Essential

internal class FeedStoreSpy: FeedStore {
	var deleteCallBack = [DeletionCompletion]()
	var insertionCompletion = [InsertionCompletion]()

	enum ReceivedMessage: Equatable {
		case deleteCacheFeed
		case insert([LocalFeedImage], Date)
	}

	private(set) var receivedMessages = [ReceivedMessage]()

	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		deleteCallBack.append(completion)
		self.receivedMessages.append(.deleteCacheFeed)
	}

	func insertFeed(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
		self.insertionCompletion.append(completion)
		self.receivedMessages.append(.insert(feed, timeStamp))
	}

	func completeDeletion(with error: NSError, at index: Int = 0) {
		deleteCallBack[index](error)
	}

	func completeDeletionSuccessfully(at index: Int = 0) {
		deleteCallBack[index](nil)
	}

	func completeInsertion(with error: NSError, at index: Int = 0) {
		insertionCompletion[index](error)
	}

	func completeInsertionSuccessfully(at index: Int = 0) {
		insertionCompletion[index](nil)
	}
}
