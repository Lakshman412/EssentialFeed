//
//  RemoteFeedLoader.swift
//  Essential
//
//  Created by lakshman-7016 on 14/04/21.
//

import Foundation

public protocol HTTPClient {
	func get(from url: URL)
}

public class RemoteFeedLoader {
	private let client: HTTPClient
	private let url: URL

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load() {
		client.get(from: url)
	}
}
