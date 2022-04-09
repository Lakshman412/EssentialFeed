//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialTests
//
//  Created by lakshman-7016 on 22/07/21.
//

import XCTest
import Essential

extension FeedStoreSpecs where Self: XCTestCase {

	func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		expect(sut, toRetrieve: .success(.none), file: file, line: line)
	}

	func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
	}

	func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let feed = uniqueImageFeed().locals
		let timestamp = Date()

		insert((feed, timestamp), to: sut)

		expect(sut, toRetrieve: .success((feed: feed, timeStamp: timestamp)), file: file, line: line)
	}

	func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let feed = uniqueImageFeed().locals
		let timestamp = Date()

		insert((feed, timestamp), to: sut)

		expect(sut, toRetrieveTwice: .success((feed: feed, timeStamp: timestamp)), file: file, line: line)
	}

	func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let insertionError = insert((uniqueImageFeed().locals, Date()), to: sut)

		XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
	}

	func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		insert((uniqueImageFeed().locals, Date()), to: sut)

		let insertionError = insert((uniqueImageFeed().locals, Date()), to: sut)

		XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
	}

	func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		insert((uniqueImageFeed().locals, Date()), to: sut)

		let latestFeed = uniqueImageFeed().locals
		let latestTimestamp = Date()
		insert((latestFeed, latestTimestamp), to: sut)

		expect(sut, toRetrieve: .success((feed: latestFeed, timeStamp: latestTimestamp)), file: file, line: line)
	}

	func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let deletionError = deleteCache(from: sut)

		XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
	}

	func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		deleteCache(from: sut)

		expect(sut, toRetrieve: .success(.none), file: file, line: line)
	}

	func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		insert((uniqueImageFeed().locals, Date()), to: sut)

		let deletionError = deleteCache(from: sut)

		XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
	}

	func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		insert((uniqueImageFeed().locals, Date()), to: sut)

		deleteCache(from: sut)

		expect(sut, toRetrieve: .success(.none), file: file, line: line)
	}

	func assertThatSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		var completedOperationsInOrder = [XCTestExpectation]()

		let op1 = expectation(description: "Operation 1")
		sut.insertFeed(uniqueImageFeed().locals, timeStamp: Date()) { _ in
			completedOperationsInOrder.append(op1)
			op1.fulfill()
		}

		let op2 = expectation(description: "Operation 2")
		sut.deleteCachedFeed { _ in
			completedOperationsInOrder.append(op2)
			op2.fulfill()
		}

		let op3 = expectation(description: "Operation 3")
		sut.insertFeed(uniqueImageFeed().locals, timeStamp: Date()) { _ in
			completedOperationsInOrder.append(op3)
			op3.fulfill()
		}

		waitForExpectations(timeout: 5.0)

		XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order", file: file, line: line)
	}

 }

extension FeedStoreSpecs where Self: XCTestCase {

	@discardableResult
	func deleteCache(from sut: FeedStore) -> Error? {
		var deletionError: Error?
		let exp = expectation(description: "Wait for deletion completion.")
		sut.deleteCachedFeed() { result in
			if case let Result.failure(error) = result {
				deletionError = error
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 10.0) // Reduce the time to 1.0 seconds
		return deletionError
	}

	@discardableResult
	func insert(_ cache: (feed: [LocalFeedImage], timeStamp: Date), to sut: FeedStore) -> Error? {
		var insertionError: Error?
		let exp = expectation(description: "Wait for cache retrieval")
		sut.insertFeed(cache.feed, timeStamp: cache.timeStamp) { result in
			if case let Result.failure(error) = result {
				insertionError = error
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		return insertionError
	}

	func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
		expect(sut, toRetrieve: expectedResult)
		expect(sut, toRetrieve: expectedResult)
	}

	func expect(_ sut: FeedStore, toRetrieve expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for cache retrieval")

		sut.retrieve() { receivedResult in
			switch (expectedResult, receivedResult) {
			case (.success(.none), .success(.none)),
				 (.failure, .failure):
				break

			case let (.success(.some((expectedFeed, expectedTimeStamp))), .success(.some((receivedFeed, receivedTimeStamp)))):
				XCTAssertEqual(expectedFeed, receivedFeed)
				XCTAssertEqual(expectedTimeStamp, receivedTimeStamp)

			default:
				XCTFail("Expected \(expectedResult), got \(receivedResult) instead")
			}
			exp.fulfill()
		}

		wait(for: [exp], timeout: 1.0)
	}
}
