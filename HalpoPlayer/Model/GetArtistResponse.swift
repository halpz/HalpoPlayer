//
//  GetArtistResponse.swift
//  HalpoPlayer
//
//  Created by paul on 20/07/2023.
//

import Foundation

// MARK: - GetArtistResponse
struct GetArtistResponse: Codable {
	let subsonicResponse: SubsonicResponse

	enum CodingKeys: String, CodingKey {
		case subsonicResponse = "subsonic-response"
	}
	
	// MARK: - SubsonicResponse
	struct SubsonicResponse: Codable {
		let status: String
		let artist: Artist
		let serverVersion, type, version: String
	}

	// MARK: - Artist
	struct Artist: Codable {
		let albumCount: Int
		let id: String
		let album: [Album]
		let name, coverArt: String
		let artistImageUrl: String
	}

	// MARK: - Album
	struct Album: Codable {
		let id, album, parent: String
		let genre: String?
		let isVideo: Bool
		let title, coverArt: String
		let songCount: Int
		let year: Int?
		let created: String
		let duration: Int
		let artistId, artist: String
		let isDir: Bool
		let name: String
	}
}


