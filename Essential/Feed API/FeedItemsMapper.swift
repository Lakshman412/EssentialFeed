//
//  FeedItemsMapper.swift
//  Essential
//
//  Created by lakshman-7016 on 04/05/21.
//

import Foundation

internal final class FeedItemsMapper {
	private struct Root: Decodable {
		let items: [Item]

		var feed: [FeedItem] {
			return items.map { $0.item }
		}
	}

	private struct Item: Decodable {
		public let id: UUID
		public let description: String?
		public let location: String?
		public let image: URL

		var item: FeedItem {
			return FeedItem(id: id, description: description, location: location, imageURL: image)
		}
	}

	static var OK_200: Int { return 200 }

	static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == 200,
			  let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.feed)
	}
}
