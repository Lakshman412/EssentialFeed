//
//  CacheFeedUseCaseTests.swift
//  EssentialTests
//
//  Created by lakshman-7016 on 20/06/21.
//

import XCTest
import Essential

class CacheFeedUseCaseTests: XCTestCase {

	func test_init_doesNotDeleteCacheUponCreation() {
		let (_, store) = makeSUT()

		XCTAssertEqual(store.receivedMessages, [])
	}

	func test_save_requestsCacheDeletion() {
		let (sut, store) = makeSUT()
		let feed = uniqueImageFeed()
		sut.save(feed.models) { _ in }
		XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
	}

	func test_save_doesNotRequestCacheInsertionOnDeletionError() {
		let (sut, store) = makeSUT()
		let feed = uniqueImageFeed()
		let deleteCacheError = anyNSError()

		sut.save(feed.models) { _ in }
		store.completeDeletion(with: deleteCacheError)

		XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
	}

	func test_save_requestsNewCacheInsertionWithTimeStampOnSuccessfulDeletion() {
		let timeStamp = Date()
		let (sut, store) = makeSUT(currentDate: { timeStamp })
		let feed = uniqueImageFeed()

		sut.save(feed.models) { _ in }
		store.completeDeletionSuccessfully()

		XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(feed.locals, timeStamp)])
	}

	func test_save_failsOnDeletionError() {
		let (sut, store) = makeSUT()
		let deletionError = anyNSError()

		expect(sut, toCompleteWith: deletionError) {
			store.completeDeletion(with: deletionError)
		}
	}

	func test_save_failsOncacheInsertionError() {
		let (sut, store) = makeSUT()
		let insertionError = anyNSError()

		self.expect(sut, toCompleteWith: insertionError) {
			store.completeDeletionSuccessfully()
			store.completeInsertion(with: insertionError)
		}
	}

	func test_save_succeedsOnSuccessfulCacheInsertion() {
		let (sut, store) = makeSUT()

		expect(sut, toCompleteWith: nil) {
			store.completeDeletionSuccessfully()
			store.completeInsertionSuccessfully()
		}
	}

	func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

		var receivedResults = [LocalFeedLoader.SaveResult]()
		sut?.save(uniqueImageFeed().models) { receivedResults.append($0) }

		sut = nil
		store.completeDeletion(with: anyNSError())

		XCTAssertTrue(receivedResults.isEmpty)
	}

	func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

		var receivedResults = [LocalFeedLoader.SaveResult]()
		sut?.save(uniqueImageFeed().models) { receivedResults.append($0) }

		store.completeDeletionSuccessfully()
		sut = nil
		store.completeInsertion(with: anyNSError())

		XCTAssertTrue(receivedResults.isEmpty)
	}

	// MARK: - Helpers

	private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}

	private func expect(_ sut: LocalFeedLoader, toCompleteWith error: NSError?, action: () -> Void) {
		let feed = [uniqueImage(), uniqueImage()]
		let exp = expectation(description: "Wait for save completion")

		var receivedError: Error?
		sut.save(feed) { result in
			if case let Result.failure(error) = result {
				receivedError = error
			}
			exp.fulfill()
		}

		action()
		wait(for: [exp], timeout: 1.0)

		XCTAssertEqual(receivedError as NSError?, error)
	}

	private func uniqueImage() -> FeedImage {
		return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
	}

	private func uniqueImageFeed() -> (models: [FeedImage], locals: [LocalFeedImage]) {
		let models = [uniqueImage(), uniqueImage()]
		let locals = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
		return (models, locals)
	}

	private func anyURL() -> URL {
		return URL(string: "https://any-url.com")!
	}

	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}
}

