//
//  CacheFeedUseCaseTests.swift
//  EssentialTests
//
//  Created by lakshman-7016 on 20/06/21.
//

import XCTest

class LocalFeedLoader {
	let store: FeedStore

	init(store: FeedStore) {
		self.store = store
	}
}

class FeedStore {
	let deleteFeedStoreCount = 0
}

class CacheFeedUseCaseTests: XCTestCase {

	func test_init_doesNotDeleteCacheUponCreation() {
		let store = FeedStore()
		_ = LocalFeedLoader(store: store)

		XCTAssertEqual(store.deleteFeedStoreCount, 0)
	}
}

