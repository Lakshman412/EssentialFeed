//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentialTests
//
//  Created by lakshman-7016 on 22/07/21.
//

import XCTest
import Essential

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
	func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		let insertionError = insert((uniqueImageFeed().locals, Date()), to: sut)

		XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
	}

	func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		insert((uniqueImageFeed().locals, Date()), to: sut)

		expect(sut, toRetrieve: .success(.empty), file: file, line: line)
	}
}
