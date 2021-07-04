//
//  FeedCachePolicy.swift
//  Essential
//
//  Created by lakshman-7016 on 04/07/21.
//

import Foundation

internal final class FeedCachePolicy {
	private init() {}
	
	private static let calendar = Calendar(identifier: .gregorian)

	private static var maxCacheAgeInDays: Int {
		return 7
	}

	internal static func validate(_ timeStamp: Date, against date: Date) -> Bool {
		guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timeStamp) else {
			return false
		}
		return date < maxCacheAge
	}
}
