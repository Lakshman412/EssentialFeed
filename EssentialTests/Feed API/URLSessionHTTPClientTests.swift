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
		session.dataTask(with: url) { _, _, _ in }
	}
}

class URLSessionHTTPClientTests: XCTestCase {

	func test_getFromURL_createDataTaskWithURL() {
		let url = URL(string: "https://any-url.com")!
		let session = URLSessionSpy()

		let sut = URLSessionHTTPClient(session: session)
		sut.get(from: url)

		XCTAssertEqual(session.receivedURLs, [url])
	}

	// MARK: - helpers

	private class URLSessionSpy: URLSession {
		var receivedURLs = [URL]()

		override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
			self.receivedURLs.append(url)
			return FakeURLSessionDataTask()
		}
	}

	private class FakeURLSessionDataTask: URLSessionDataTask {}
}
