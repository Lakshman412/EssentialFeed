//
//  FeedLoader.swift
//  Essential
//
//  Created by lakshman-7016 on 14/04/21.
//

import Foundation

public protocol FeedLoader {
	typealias Result = Swift.Result<[FeedImage], Error>

	func load(completion: @escaping (Result) -> Void)
}
