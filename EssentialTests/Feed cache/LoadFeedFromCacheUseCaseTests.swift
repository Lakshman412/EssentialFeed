//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialTests
//
//  Created by lakshman-7016 on 23/06/21.
//

import XCTest
import Essential

class LoadFeedFromCacheUseCaseTests: XCTestCase {

	func test_init_doesNotMessageStoreUponCreation() {
		let (_, store) = makeSUT()

		XCTAssertEqual(store.receivedMessages, [])
	}

	func test_load_requestsCacheRetrieval() {
		let (sut, store) = makeSUT()

		sut.load() { _ in }

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_load_failsOnRetrievalError() {
		let (sut, store) = makeSUT()
		let retrievalError = anyNSError()

		expect(sut, toCompleteWith: .failure(retrievalError)) {
			store.completeRetrieval(with: retrievalError)
		}
	}

	func test_load_deliversNoImageOnEmptyCache() {
		let (sut, store) = makeSUT()

		expect(sut, toCompleteWith: .success([])) {
			store.completeRetrievalSuccessfully()
		}
	}

	func test_load_deliversCachedImagesOnNonExpiredCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let nonExpiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
		let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

		expect(sut, toCompleteWith: .success(feed.models)) {
			store.completeRetrieval(with: feed.locals, timeStamp: nonExpiredTimeStamp)
		}
	}

	func test_load_deliversNoImagesOnCacheExpiration() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let expirationTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge()
		let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

		expect(sut, toCompleteWith: .success([])) {
			store.completeRetrieval(with: feed.locals, timeStamp: expirationTimeStamp)
		}
	}

	func test_load_deliversNoImagesOnExpiredCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let expiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
		let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

		expect(sut, toCompleteWith: .success([])) {
			store.completeRetrieval(with: feed.locals, timeStamp: expiredTimeStamp)
		}
	}

	func test_load_hasNOSideEffectsOnRetrievalError() {
		let (sut, store) = makeSUT()

		sut.load() { _ in }
		store.completeRetrieval(with: anyNSError())

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_load_hasNoSideEffectsOnEmptyCache() {
		let (sut, store) = makeSUT()

		sut.load() { _ in }
		store.completeRetrievalSuccessfully()

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_load_hasNoSideEffectsOnNonExpiredCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let nonExpiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
		let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })


		sut.load() { _ in }
		store.completeRetrieval(with: feed.locals, timeStamp: nonExpiredTimeStamp)

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_load_hasNoSideEffectsOnCacheExpiration() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let expirationTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge()
		let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })


		sut.load() { _ in }
		store.completeRetrieval(with: feed.locals, timeStamp: expirationTimeStamp)

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_load_hasNoSideEffectsOnExpiredCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let expiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
		let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })


		sut.load() { _ in }
		store.completeRetrieval(with: feed.locals, timeStamp: expiredTimeStamp)

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_load_doesNotDeliversResultAfterSUTInstanceDeallocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

		var receivedResults = [FeedLoader.Result]()
		sut?.load() { receivedResults.append($0) }

		sut = nil
		store.completeRetrievalWithEmptyCache()

		XCTAssert(receivedResults.isEmpty)
	}

//	MARK: - Helpers

	private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}

	private func expect(_ sut: LocalFeedLoader, toCompleteWith result: FeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		let exp = expectation(description: "Wait for completion")
		sut.load() { receivedResult in
			switch (receivedResult, result) {
			case let (.success(receivedFeed), .success(expectedFeed)):
				XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
			case let (.failure(receivedError), .failure(expectedError)):
				XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)
			default:
				XCTFail("Expected \(result), got \(receivedResult) instead", file: file, line: line)
			}
			exp.fulfill()
		}

		action()
		wait(for: [exp], timeout: 1.0)
	}
}
