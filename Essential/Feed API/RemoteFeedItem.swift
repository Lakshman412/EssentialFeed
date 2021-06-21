//
//  RemoteFeedItem.swift
//  Essential
//
//  Created by lakshman-7016 on 21/06/21.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
	let id: UUID
	let description: String?
	let location: String?
	let image: URL
}
