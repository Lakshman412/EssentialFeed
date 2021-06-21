//
//  LocalFeedItem.swift
//  Essential
//
//  Created by lakshman-7016 on 21/06/21.
//

import Foundation

public struct LocalFeedItem: Equatable {
	public let id: UUID
	public let description: String?
	public let location: String?
	public let imageURL: URL

	public init(id: UUID, description: String?, location: String?, imageURL: URL) {
		self.id = id
		self.description = description
		self.location = location
		self.imageURL = imageURL
	}
}
