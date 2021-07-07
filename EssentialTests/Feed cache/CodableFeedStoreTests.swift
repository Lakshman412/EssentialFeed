//
//  CodableFeedStoreTests.swift
//  EssentialTests
//
//  Created by lakshman-7016 on 07/07/21.
//

import XCTest
import Essential

class CodableFeedStore {
	private struct Cache: Codable {
		let feed: [LocalFeedImage]
		let timestamp: Date
	}

	private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")

	func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
		guard let data = try? Data(contentsOf: storeURL) else {
			completion(.empty)
			return
		}
		let decoder = JSONDecoder()
		let cache = try! decoder.decode(Cache.self, from: data)
		completion(.found(feed: cache.feed, timeStamp: cache.timestamp))
	}

	func insertFeed(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
		let encoder = JSONEncoder()
		let encoded = try! encoder.encode(Cache(feed: feed, timestamp: timeStamp))
		try! encoded.write(to: storeURL)
		completion(nil)
	}
}

class CodableFeedStoreTests: XCTestCase {

	override func setUp() {
		super.setUp()

		let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
		try? FileManager.default.removeItem(at: storeURL)
	}

	override func tearDown() {
		super.tearDown()

		let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
		try? FileManager.default.removeItem(at: storeURL)
	}

	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = CodableFeedStore()

		let exp = expectation(description: "Wait for cache retrieval")

		sut.retrieve() { result in
			switch result {
			case .empty:
				break
			default:
				XCTFail("Expected empty result, got \(result) instead")
			}
			exp.fulfill()
		}

		wait(for: [exp], timeout: 1.0)
	}

	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = CodableFeedStore()

		let exp = expectation(description: "Wait for cache retrieval")

		sut.retrieve() { firstResult in
			sut.retrieve() { secondResult in
				switch (firstResult, secondResult) {
				case (.empty, .empty):
					break
				default:
					XCTFail("Expected retrieving twice from empty cache delivers same empty result, got \(firstResult) and \(secondResult) instead")
				}
			}
			exp.fulfill()
		}

		wait(for: [exp], timeout: 1.0)
	}

	func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
		let sut = CodableFeedStore()
		let feed = uniqueImageFeed().locals
		let timestamp = Date()
		let exp = expectation(description: "Wait for cache retrieval")

		sut.insertFeed(feed, timeStamp: timestamp) { insertionError in
			XCTAssertNil(insertionError, "successfull insertion to cache")

			sut.retrieve() { result in
				switch result {
				case let .found(receivedFeed, receivedTimeStamp):
					XCTAssertEqual(receivedFeed, feed)
					XCTAssertEqual(receivedTimeStamp, timestamp)
				default:
					XCTFail("expected found result with \(feed) and \(timestamp), got \(result) instead")
				}
				exp.fulfill()
			}
		}

		wait(for: [exp], timeout: 1.0)
	}
}
