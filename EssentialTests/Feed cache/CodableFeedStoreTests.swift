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
		let feed: [CodableFeedImage]
		let timestamp: Date

		var localFeed: [LocalFeedImage] {
			return feed.map { $0.local }
		}
	}

	private struct CodableFeedImage: Codable {
		private let id: UUID
		private let description: String?
		private let location: String?
		private let url: URL

		init(_ image: LocalFeedImage) {
			self.id = image.id
			self.description = image.description
			self.location = image.location
			self.url = image.url
		}

		var local: LocalFeedImage {
			return LocalFeedImage(id: self.id, description: self.description, location: self.location, url: self.url)
		}
	}

	private let storeURL: URL

	init(storeURL: URL) {
		self.storeURL = storeURL
	}

	func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
		guard let data = try? Data(contentsOf: storeURL) else {
			completion(.empty)
			return
		}
		let decoder = JSONDecoder()
		let cache = try! decoder.decode(Cache.self, from: data)
		completion(.found(feed: cache.localFeed, timeStamp: cache.timestamp))
	}

	func insertFeed(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
		let encoder = JSONEncoder()
		let encoded = try! encoder.encode(Cache(feed: feed.map(CodableFeedImage.init), timestamp: timeStamp))
		try! encoded.write(to: storeURL)
		completion(nil)
	}
}

class CodableFeedStoreTests: XCTestCase {

	override func setUp() {
		super.setUp()

		try? FileManager.default.removeItem(at: self.testSpecificStoreURL())
	}

	override func tearDown() {
		super.tearDown()

		try? FileManager.default.removeItem(at: self.testSpecificStoreURL())
	}

	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()

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
		let sut = makeSUT()

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
		let sut = makeSUT()
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

	// MARK: - Helpers

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
		let sut = CodableFeedStore(storeURL: self.testSpecificStoreURL())
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}

	private func testSpecificStoreURL() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
	}
}
