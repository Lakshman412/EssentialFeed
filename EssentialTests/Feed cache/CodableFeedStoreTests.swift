//
//  CodableFeedStoreTests.swift
//  EssentialTests
//
//  Created by lakshman-7016 on 07/07/21.
//

import XCTest
import Essential

class CodableFeedStoreTests: XCTestCase {

	override func setUp() {
		super.setUp()

		setUpEmptyStoreState()
	}

	override func tearDown() {
		super.tearDown()

		undoStoreSideEffects()
	}

	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()

		expect(sut, toRetrieve: .empty)
	}

	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

		expect(sut, toRetrieveTwice: .empty)
	}

	func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
		let sut = makeSUT()
		let feed = uniqueImageFeed().locals
		let timestamp = Date()

		insert((feed, timestamp), to: sut)

		expect(sut, toRetrieve: .found(feed: feed, timeStamp: timestamp))
	}

	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
		let sut = makeSUT()
		let feed = uniqueImageFeed().locals
		let timestamp = Date()

		insert((feed, timestamp), to: sut)

		expect(sut, toRetrieveTwice: .found(feed: feed, timeStamp: timestamp))
	}

	func test_retrieve_deliversFailureOnRetrievalError() {
		let storeURL = testSpecificStoreURL()
		let sut = makeSUT(storeURL: storeURL)

		try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

		expect(sut, toRetrieve: .failure(anyNSError()))
	}

	func test_retrieve_hasNoSideEffectsOnFailure() {
		let storeURL = testSpecificStoreURL()
		let sut = makeSUT(storeURL: storeURL)

		try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

		expect(sut, toRetrieveTwice: .failure(anyNSError()))
	}

	func test_insert_overridesPreviouslyInsertedCacheValues() {
		let sut = makeSUT()

		let firstInsertionError = insert((uniqueImageFeed().locals, Date()), to: sut)
		XCTAssertNil(firstInsertionError, "successfull insertion to cache")

		let secondFeed = uniqueImageFeed().locals
		let secondTimeStamp = Date()
		let secondInsertionError = insert((secondFeed, secondTimeStamp), to: sut)
		XCTAssertNil(secondInsertionError, "successfull insertion to cache")

		expect(sut, toRetrieve: .found(feed: secondFeed, timeStamp: secondTimeStamp))
	}

	func test_insert_deliversErrorOnInsertionError() {
		let invalidStoreURL = URL(string: "invalid://store-url")!
		let sut = makeSUT(storeURL: invalidStoreURL)
		let feed = uniqueImageFeed().locals
		let timeStamp = Date()

		let insertionError = insert((feed, timeStamp), to: sut)

		XCTAssertNotNil(insertionError, "Expected Cache insertion to fail with an error")
	}

	func test_delete_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

		let deletionError = deleteCache(from: sut)

		XCTAssertNil(deletionError, "Expected cache deletion successfully.")
		expect(sut, toRetrieve: .empty)
	}

	func test_delete_emptiesPreviouslyInsertedCache() {
		let sut = makeSUT()

		insert((uniqueImageFeed().locals, Date()), to: sut)
		let deletionError = deleteCache(from: sut)

		XCTAssertNil(deletionError, "Expected cache deletion successfully.")
		expect(sut, toRetrieve: .empty)
	}

	func test_delete_deliversErrorOnDeletionError() {
		let noDeletePermissionURL = cachesDirectory()
		let sut = makeSUT(storeURL: noDeletePermissionURL)

		let deletionError = deleteCache(from: sut)

		XCTAssertNotNil(deletionError, "Expected deletion to complete with error")
		expect(sut, toRetrieve: .empty)
	}

	// MARK: - Helpers

	private func makeSUT(storeURL: URL? = nil,file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
		let sut = CodableFeedStore(storeURL: storeURL ?? self.testSpecificStoreURL())
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}

	private func deleteCache(from sut: FeedStore) -> Error? {
		var deletionError: Error?
		let exp = expectation(description: "Wait for deletion completion.")
		sut.deleteCachedFeed() { error in
			deletionError = error
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
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

	private func cachesDirectory() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
	}

	func setUpEmptyStoreState() {
		self.deleteStoreArtifacts()
	}

	func undoStoreSideEffects() {
		self.deleteStoreArtifacts()
	}

	func deleteStoreArtifacts() {
		try? FileManager.default.removeItem(at: self.testSpecificStoreURL())
	}

	private func testSpecificStoreURL() -> URL {
		return self.cachesDirectory().appendingPathComponent("\(type(of: self)).store")
	}
}
