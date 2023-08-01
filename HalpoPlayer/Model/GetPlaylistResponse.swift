//
//  GetPlaylistResponse.swift
//  HalpoPlayer
//
//  Created by paul on 18/07/2023.
//

import Foundation

// MARK: - GetPlaylistResponse
struct GetPlaylistResponse: Codable {
	let subsonicResponse: SubsonicResponse

	enum CodingKeys: String, CodingKey {
		case subsonicResponse = "subsonic-response"
	}
	
	// MARK: - SubsonicResponse
	struct SubsonicResponse: Codable {
		let status: String
		let playlist: Playlist
		let serverVersion, type, version: String
	}

	// MARK: - Playlist
	struct Playlist: Codable {
		let playlistPublic: Bool
		let owner: String
		let entry: [Entry]?
		let id, coverArt: String
		let duration, songCount: Int
		let created, name, changed: String
		let comment: String?

		enum CodingKeys: String, CodingKey {
			case playlistPublic = "public"
			case owner, entry, id, coverArt, duration, songCount, created, comment, name, changed
		}
	}

	// MARK: - Entry
	struct Entry: Codable, Hashable {
		let suffix, title: String
		let bitRate: Int
		let isVideo: Bool
		let duration: Int
		let path: String
		let artistId: String?
		let year: Int
		let parent: String
		let size: Int
		let albumId, type, id, artist: String
		let contentType: String
		let isDir: Bool
		let album, coverArt, created: String
		let genre: String?
	}
}


