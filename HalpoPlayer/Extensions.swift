//
//  Extensions.swift
//  halpoplayer
//
//  Created by paul on 10/07/2023.
//

import Foundation

extension Array where Element : Equatable {
	public subscript(safe bounds: Range<Int>) -> ArraySlice<Element> {
		if bounds.lowerBound > count { return [] }
		let lower = Swift.max(0, bounds.lowerBound)
		let upper = Swift.max(0, Swift.min(count, bounds.upperBound))
		return self[lower..<upper]
	}
	
	public subscript(safe lower: Int?, _ upper: Int?) -> ArraySlice<Element> {
		let lower = lower ?? 0
		let upper = upper ?? count
		if lower > upper { return [] }
		return self[safe: lower..<upper]
	}
}
