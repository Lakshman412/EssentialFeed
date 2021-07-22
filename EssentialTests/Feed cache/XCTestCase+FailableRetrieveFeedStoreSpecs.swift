//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift
//  EssentialTests
//
//  Created by lakshman-7016 on 22/07/21.
//

import XCTest
import Essential

extension FailableRetrieveFeedStoreSpecs where Self: XCTestCase {
	func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		expect(sut, toRetrieve: .failure(anyNSError()), file: file, line: line)
	}

	func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
		expect(sut, toRetrieveTwice: .failure(anyNSError()), file: file, line: line)
	}
}
