//
//  RemoteFeedLoaderTests.swift
//  EssentialTests
//
//  Created by lakshman-7016 on 14/04/21.
//

import XCTest
import Essential

class RemoteFeedLoaderTests: XCTestCase {

	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()

		XCTAssertTrue(client.requestedURLs.isEmpty)
	}

	func test_load_requestDataFromURL() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		sut.load()

		XCTAssertEqual(client.requestedURLs, [url])
	}

	func test_loadTwice_requestsDataFromURLTwice() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		sut.load()
		sut.load()

		XCTAssertEqual(client.requestedURLs, [url, url])
	}

	func test_load_deliversErrorOnClientErrors() {
		let (sut, client) = makeSUT()
		let clientError = NSError(domain: "Test", code: 0)

		var capturedError = [RemoteFeedLoader.Error]()
		sut.load() { capturedError.append($0) }

		client.complete(with: clientError)

		XCTAssertEqual(capturedError, [.connectivity])
	}

	// MARK: - Helpers

	private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		return (sut, client)
	}

	private class HTTPClientSpy: HTTPClient {
		var messages = [(url: URL, completion: (Error) -> Void)]()

		var requestedURLs: [URL] {
			return messages.map { $0.url }
		}

		func get(from url: URL, completion: @escaping (Error) -> Void) {
			messages.append((url, completion))
		}

		func complete(with error: Error, at index: Int = 0) {
			messages[index].completion(error)
		}
	}
}
