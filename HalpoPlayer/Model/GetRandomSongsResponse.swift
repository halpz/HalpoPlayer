//
//  GetRandomSongsResponse.swift
//  halpoplayer
//
//  Created by Paul Halpin on 09/07/2023.
//

import Foundation

// MARK: - GetRandomSongsResponse
struct GetRandomSongsResponse: Codable {
	let subsonicResponse: SubsonicResponse
	
	enum CodingKeys: String, CodingKey {
		case subsonicResponse = "subsonic-response"
	}
	
	// MARK: - SubsonicResponse
	struct SubsonicResponse: Codable {
		let status: String
		let randomSongs: RandomSongs
		let serverVersion, type, version: String
	}
	
	// MARK: - RandomSongs
	struct RandomSongs: Codable {
		let song: [Song]
	}
	
	// MARK: - Song
	struct Song: Codable {
		let suffix, title: String
		let bitRate: Int
		let isVideo: Bool
		let duration: Int
		let artistId: String?
		let path: String
		let played: String?
		let year: Int?
		let parent: String
		let track: Int?
		let size: Int
		let playCount: Int?
		let id, albumId, type, artist: String
		let contentType: String
		let isDir: Bool
		let genre: String?
		let album, coverArt, created: String
		let discNumber: Int?
	}
	
	
}

