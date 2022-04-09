//
//  CodableFeedStore.swift
//  Essential
//
//  Created by lakshman-7016 on 18/07/21.
//

import Foundation

public class CodableFeedStore: FeedStore {
	private struct Cache: Codable {
		let feed: [CodableFeedImage]
		let timestamp: Date

		var localFeed: [LocalFeedImage] {
			return feed.map { $0.local }
		}
	}

	private struct CodableFeedImage: Codable {
		private let id: UUID
		private let description: String?
		private let location: String?
		private let url: URL

		init(_ image: LocalFeedImage) {
			self.id = image.id
			self.description = image.description
			self.location = image.location
			self.url = image.url
		}

		var local: LocalFeedImage {
			return LocalFeedImage(id: self.id, description: self.description, location: self.location, url: self.url)
		}
	}

	private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
	private let storeURL: URL

	public init(storeURL: URL) {
		self.storeURL = storeURL
	}

	public func retrieve(completion: @escaping RetrievalCompletion) {
		let storeURL = self.storeURL
		queue.async {
			guard let data = try? Data(contentsOf: storeURL) else {
				completion(.success(.none))
				return
			}
			do {
				let decoder = JSONDecoder()
				let cache = try decoder.decode(Cache.self, from: data)
				completion(.success((feed: cache.localFeed, timeStamp: cache.timestamp)))
			} catch {
				completion(.failure(error))
			}
		}
	}

	public func insertFeed(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
		let storeURL = self.storeURL
		queue.async(flags: .barrier) {
			do {
				let encoder = JSONEncoder()
				let encoded = try encoder.encode(Cache(feed: feed.map(CodableFeedImage.init), timestamp: timeStamp))
				try encoded.write(to: storeURL)
				completion(.success(()))
			} catch {
				completion(.failure(error))
			}
		}
	}

	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		queue.async(flags: .barrier) { [storeURL] in // alternate for capturing storeURL unlike above methods
			guard FileManager.default.fileExists(atPath: storeURL.path) else {
				return completion(.success(()))
			}
			do {
				try FileManager.default.removeItem(at: storeURL)
				completion(.success(()))
			} catch {
				completion(.failure(error))
			}
		}
	}
}
