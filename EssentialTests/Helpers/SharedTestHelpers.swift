//
//  SharedTestHelpers.swift
//  EssentialTests
//
//  Created by lakshman-7016 on 30/06/21.
//

import Foundation
import Essential

func anyNSError() -> NSError {
	return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
	return URL(string: "https://any-url.com")!
}

