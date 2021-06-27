//
//  LocalFeedLoader.swift
//  Essential
//
//  Created by lakshman-7016 on 20/06/21.
//

import Foundation

public class LocalFeedLoader {
	private let store: FeedStore
	private let currentDate: () -> Date
	private let calendar = Calendar(identifier: .gregorian)

	public typealias SaveResult = Error?

	public init(store: FeedStore, currentDate: @escaping () -> Date) {
		self.store = store
		self.currentDate = currentDate
	}

	public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
		store.deleteCachedFeed { [weak self] error in
			guard let self = self else { return }

			if let cacheDeletionError = error {
				completion(cacheDeletionError)
			} else {
				self.cache(feed, with: completion)
			}
		}
	}

	public func load(completion: @escaping (LoadFeedResult) -> Void) {
		store.retrieve() { [unowned self] retrievedResult in
			switch retrievedResult {
			case .failure(let error):
				completion(.failure(error))
			case let .found(feed, timeStamp) where self.validate(timeStamp):
				completion(.success(feed.toModels()))
			case .found, .empty:
				completion(.success([]))
			}
		}
	}

	private func validate(_ timeStamp: Date) -> Bool {
		guard let maxCacheAge = calendar.date(byAdding: .day, value: 7, to: timeStamp) else {
			return false
		}
		return currentDate() < maxCacheAge
	}

	private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
		store.insertFeed(feed.toLocal(), timeStamp: currentDate()) { [weak self] error in
			guard self != nil else { return }
			completion(error)
		}
	}
}

extension Array where Element == FeedImage {
	func toLocal() -> [LocalFeedImage] {
		map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
	}
}

extension Array where Element == LocalFeedImage {
	func toModels() -> [FeedImage] {
		map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
	}
}
