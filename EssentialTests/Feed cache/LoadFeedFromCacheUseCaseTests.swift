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
		var receivedError: Error?
		let retrievalError = anyNSError()

		sut.load() { result in
			switch result {
			case let .failure(error):
				receivedError = error
			default:
				XCTFail("Expected failure, got \(result) instead")
			}
		}

		store.completeRetrieval(with: retrievalError)

		XCTAssertEqual(receivedError as NSError?, retrievalError)
	}

	func test_load_deliversNoImageOnEmptyCache() {
		let (sut, store) = makeSUT()
		var receivedImage: [FeedImage]?

		sut.load() { result in
			switch result {
			case .success(let feed):
				receivedImage = feed
			default:
				XCTFail("Expected success, got \(result) instead")
			}
		}

		store.completeRetrievalSuccessfully()

		XCTAssertEqual(receivedImage, [])
	}

//	MARK: - Helpers

	private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}

	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}
}
