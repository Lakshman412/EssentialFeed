//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialTests
//
//  Created by lakshman-7016 on 30/06/21.
//

import XCTest
import Essential

class ValidateFeedCacheUseCaseTests: XCTestCase {
	func test_init_doesNotMessageStoreUponCreation() {
		let (_, store) = makeSUT()

		XCTAssertEqual(store.receivedMessages, [])
	}

	func test_validateCache_deletesCacheOnRetrievalError() {
		let (sut, store) = makeSUT()

		sut.validateCache()
		store.completeRetrieval(with: anyNSError())

		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
	}

	func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
		let (sut, store) = makeSUT()

		sut.validateCache()
		store.completeRetrievalSuccessfully()

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_validateCache_doesNotDeleteCacheOnLessThanSevenDaysOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let lessThanSevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
		let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })


		sut.validateCache()
		store.completeRetrieval(with: feed.locals, timeStamp: lessThanSevenDaysOldTimeStamp)

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_validateCache_deleteCacheOnSevenDaysOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let sevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7)
		let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })


		sut.validateCache()
		store.completeRetrieval(with: feed.locals, timeStamp: sevenDaysOldTimeStamp)

		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
	}

	func test_validateCache_deleteCacheOnMoreThanSevenDaysOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let moreThanSevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
		let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })


		sut.validateCache()
		store.completeRetrieval(with: feed.locals, timeStamp: moreThanSevenDaysOldTimeStamp)

		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
	}

	func test_validateCache_doesNotDeliversResultAfterSUTInstanceDeallocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

		sut?.validateCache()

		sut = nil
		store.completeRetrieval(with: anyNSError())

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

//	MARK: - Helpers

	private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}
}
