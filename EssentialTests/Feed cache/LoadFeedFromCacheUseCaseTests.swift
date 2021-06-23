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

//	MARK: - Helpers

	private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}

	private func expect(_ sut: LocalFeedLoader, toCompleteWith result: LoadFeedResult, when action: () -> Void) {
		let exp = expectation(description: "Wait for completion")
		sut.load() { receivedResult in
			switch (receivedResult, result) {
			case let (.success(receivedFeed), .success(expectedFeed)):
				XCTAssertEqual(receivedFeed, expectedFeed)
			case let (.failure(receivedError), .failure(expectedError)):
				XCTAssertEqual(receivedError as NSError, expectedError as NSError)
			default:
				XCTFail("Expected \(result), got \(receivedResult) instead")
			}
			exp.fulfill()
		}

		action()
		wait(for: [exp], timeout: 1.0)
	}

	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}
}
