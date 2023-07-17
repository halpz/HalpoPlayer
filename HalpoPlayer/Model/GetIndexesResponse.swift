//
//  GetIndexesResponse.swift
//  halpoplayer
//
//  Created by Paul Halpin on 08/07/2023.
//

import Foundation

// MARK: - GetIndexesResponse
struct GetIndexesResponse: Codable {
	let subsonicResponse: SubsonicResponse
	
	enum CodingKeys: String, CodingKey {
		case subsonicResponse = "subsonic-response"
	}
	
	// MARK: - SubsonicResponse
	struct SubsonicResponse: Codable {
		let status: String
		let indexes: Indexes
		let serverVersion, type, version: String
	}
	
	// MARK: - Indexes
	struct Indexes: Codable {
		let index: [Index]
		let lastModified: Int
		let ignoredArticles: String
	}
	
	// MARK: - Index
	struct Index: Codable {
		let name: String
		let artist: [Artist]
	}
	
	// MARK: - Artist
	struct Artist: Codable {
		let albumCount: Int
		let id, name, coverArt: String
		let artistImageUrl: String
	}
}
