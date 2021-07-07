//
//  LocalFeedItem.swift
//  Essential
//
//  Created by lakshman-7016 on 21/06/21.
//

import Foundation

public struct LocalFeedImage: Equatable, Codable {
	public let id: UUID
	public let description: String?
	public let location: String?
	public let url: URL

	public init(id: UUID, description: String?, location: String?, url: URL) {
		self.id = id
		self.description = description
		self.location = location
		self.url = url
	}
}
