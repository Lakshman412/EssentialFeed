//
//  URLSessionHTTPClientTests.swift
//  EssentialTests
//
//  Created by lakshman-7016 on 20/05/21.
//

import Foundation
import XCTest
import Essential

class URLSessionHTTPClient {
	private let session: URLSession

	init(session: URLSession) {
		self.session = session
	}

	func get(from url: URL ,completion: @escaping (HTTPClientResult) -> Void) {
		session.dataTask(with: url) { _, _, error in
			if let error = error {
				completion(.failure(error))
			}
		}.resume()
	}
}

class URLSessionHTTPClientTests: XCTestCase {
	func test_getFromURL_resumeDataTaskWithURL() {
		let url = URL(string: "https://any-url.com")!
		let session = URLSessionSpy()
		let task = URLSessionDataTaskSpy()
		session.stub(url: url, task: task)

		let sut = URLSessionHTTPClient(session: session)
		sut.get(from: url) { _ in }

		XCTAssertEqual(task.resumeCount, 1)
	}

	func test_getFromURL_failsOnRequestError() {
		let url = URL(string: "https://any-url.com")!
		let session = URLSessionSpy()
		let error = NSError(domain: "any error", code: 1)
		session.stub(url: url, error: error)

		let sut = URLSessionHTTPClient(session: session)

		let exp = expectation(description: "Wait for completion")
		sut.get(from: url) { result in
			switch result {
			case let .failure(requestError as NSError):
				XCTAssertEqual(error, requestError)
			default:
				XCTFail("Expected failure with error \(error), got \(result) instead")
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}

	// MARK: - helpers

	private class URLSessionSpy: URLSession {
		var stubs = [URL: Stub]()

		struct Stub {
			let task: URLSessionDataTask
			let error: Error?
		}

		func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: NSError? = nil) {
			self.stubs[url] = Stub(task: task, error: error)
		}

		override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
			guard let stub = stubs[url] else {
				fatalError("Couln't find stub for \(url)")
			}
			completionHandler(nil, nil, stub.error)
			return stub.task
		}
	}

	private class FakeURLSessionDataTask: URLSessionDataTask {}

	private class URLSessionDataTaskSpy: URLSessionDataTask {
		var resumeCount = 0

		override func resume() {
			self.resumeCount += 1
		}
	}
}
