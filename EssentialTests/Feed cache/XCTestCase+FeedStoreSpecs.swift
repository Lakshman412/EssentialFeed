//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialTests
//
//  Created by lakshman-7016 on 22/07/21.
//

import XCTest
import Essential

extension FeedStoreSpecs where Self: XCTestCase {

	@discardableResult
	func deleteCache(from sut: FeedStore) -> Error? {
		var deletionError: Error?
		let exp = expectation(description: "Wait for deletion completion.")
		sut.deleteCachedFeed() { error in
			deletionError = error
			exp.fulfill()
		}
		wait(for: [exp], timeout: 10.0) // Reduce the time to 1.0 seconds
		return deletionError
	}

	@discardableResult
	func insert(_ cache: (feed: [LocalFeedImage], timeStamp: Date), to sut: FeedStore) -> Error? {
		var insertionError: Error?
		let exp = expectation(description: "Wait for cache retrieval")
		sut.insertFeed(cache.feed, timeStamp: cache.timeStamp) { error in
			insertionError = error
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		return insertionError
	}

	func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
		expect(sut, toRetrieve: expectedResult)
		expect(sut, toRetrieve: expectedResult)
	}

	func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for cache retrieval")

		sut.retrieve() { receivedResult in
			switch (expectedResult, receivedResult) {
			case (.empty, .empty),
				 (.failure, .failure):
				break

			case let (.found(expectedFeed, expectedTimeStamp), .found(receivedFeed, receivedTimeStamp)):
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
