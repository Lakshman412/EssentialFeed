//
//  URLSessionHTTPClientTests.swift
//  EssentialTests
//
//  Created by lakshman-7016 on 20/05/21.
//

import Foundation
import XCTest

class URLSessionHTTPClient {
	private let session: URLSession

	init(session: URLSession) {
		self.session = session
	}

	func get(from url: URL) {
		session.dataTask(with: url) { _, _, _ in }.resume()
	}
}

class URLSessionHTTPClientTests: XCTestCase {
	func test_getFromURL_resumeDataTaskWithURL() {
		let url = URL(string: "https://any-url.com")!
		let session = URLSessionSpy()
		let task = URLSessionDataTaskSpy()
		session.stub(url: url, task: task)

		let sut = URLSessionHTTPClient(session: session)
		sut.get(from: url)

		XCTAssertEqual(task.resumeCount, 1)
	}

	// MARK: - helpers

	private class URLSessionSpy: URLSession {
		var stubs = [URL: URLSessionDataTask]()

		func stub(url: URL, task: URLSessionDataTask) {
			self.stubs[url] = task
		}

		override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
			return stubs[url] ?? FakeURLSessionDataTask()
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
