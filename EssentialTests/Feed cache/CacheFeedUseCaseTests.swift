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
	let currentDate: () -> Date

	init(store: FeedStore, currentDate: @escaping () -> Date) {
		self.store = store
		self.currentDate = currentDate
	}

	func save(_ items: [FeedItem]) {
		store.deleteCachedFeed { [unowned self] error in
			if error == nil {
				self.store.insertFeed(items, timeStamp: self.currentDate())
			}
		}
	}
}

class FeedStore {
	typealias DeletionCompletion = (Error?) -> Void
	var deleteCAchedFeedCallCount = 0
	var insertions = [(items: [FeedItem], timeStamp: Date)]()
	var deleteCallBack = [DeletionCompletion]()

	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		self.deleteCAchedFeedCallCount += 1
		deleteCallBack.append(completion)
	}

	func insertFeed(_ items: [FeedItem], timeStamp: Date) {
		self.insertions.append((items, timeStamp))
	}

	func completeDeletion(with error: NSError, at index: Int = 0) {
		deleteCallBack[index](error)
	}

	func completeDeletionSuccessfully(at index: Int = 0) {
		deleteCallBack[index](nil)
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

	func test_save_doesNotRequestCacheInsertionOnDeletionError() {
		let (sut, store) = makeSUT()
		let items = [uniqueItems()]
		let deleteCacheError = anyNSError()

		sut.save(items)
		store.completeDeletion(with: deleteCacheError)

		XCTAssertEqual(store.deleteCAchedFeedCallCount, 1)
	}

	func test_save_requestsNewCacheInsertionWithTimeStampOnSuccessfulDeletion() {
		let timeStamp = Date()
		let (sut, store) = makeSUT(currentDate: { timeStamp })
		let items = [uniqueItems()]

		sut.save(items)
		store.completeDeletionSuccessfully()

		XCTAssertEqual(store.insertions.count, 1)
		XCTAssertEqual(store.insertions.first?.items, items)
		XCTAssertEqual(store.insertions.first?.timeStamp, timeStamp)
	}

	// MARK: - Helpers

	func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (LocalFeedLoader, FeedStore) {
		let store = FeedStore()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}

	private func uniqueItems() -> FeedItem {
		return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
	}

	private func anyURL() -> URL {
		return URL(string: "https://any-url.com")!
	}

	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}
}

