//
//  HTTPClient.swift
//  Essential
//
//  Created by lakshman-7016 on 04/05/21.
//

import Foundation

public protocol HTTPClient {
	typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

	func get(from url: URL, completion: @escaping (Result) -> Void)
}
