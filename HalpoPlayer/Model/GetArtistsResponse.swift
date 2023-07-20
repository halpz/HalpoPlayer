//
//  GetArtistsResponse.swift
//  HalpoPlayer
//
//  Created by paul on 20/07/2023.
//

import Foundation

// MARK: - GetArtistsResponse
struct GetArtistsResponse: Codable {
	let subsonicResponse: SubsonicResponse

	enum CodingKeys: String, CodingKey {
		case subsonicResponse = "subsonic-response"
	}
	
	// MARK: - SubsonicResponse
	struct SubsonicResponse: Codable {
		let status, serverVersion, type: String
		let artists: Artists
		let version: String
	}

	// MARK: - Artists
	struct Artists: Codable {
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


