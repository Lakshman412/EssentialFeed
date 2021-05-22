//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialTests
//
//  Created by lakshman-7016 on 22/05/21.
//

import Foundation
import XCTest

extension XCTestCase {
	func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
		}
	}
}
