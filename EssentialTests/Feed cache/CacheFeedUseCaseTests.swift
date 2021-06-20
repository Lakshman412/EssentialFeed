//
//  CacheFeedUseCaseTests.swift
//  EssentialTests
//
//  Created by lakshman-7016 on 20/06/21.
//

import XCTest
import Essential

class LocalFeedLoader {
	let store: FeedStore

	init(store: FeedStore) {
		self.store = store
	}

	func save(_ items: [FeedItem]) {
		store.deleteCachedFeed()
	}
}

class FeedStore {
	var deleteCAchedFeedCallCount = 0

	func deleteCachedFeed() {
		self.deleteCAchedFeedCallCount += 1
	}
}

class CacheFeedUseCaseTests: XCTestCase {

	func test_init_doesNotDeleteCacheUponCreation() {
		let (_, store) = makeSUT()

		XCTAssertEqual(store.deleteCAchedFeedCallCount, 0)
	}

	func test_save_requestsCacheDeletion() {
		let (sut, store) = makeSUT()
		let items = [uniqueItems()]
		sut.save(items)
		XCTAssertEqual(store.deleteCAchedFeedCallCount, 1)
	}

	// MARK: - Helpers

	func makeSUT() -> (LocalFeedLoader, FeedStore) {
		let store = FeedStore()
		let sut = LocalFeedLoader(store: store)
		return (sut, store)
	}

	private func uniqueItems() -> FeedItem {
		return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
	}

	private func anyURL() -> URL {
		return URL(string: "https://any-url.com")!
	}
}

