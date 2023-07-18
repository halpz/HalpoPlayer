//
//  GetPlaylistsResponse.swift
//  HalpoPlayer
//
//  Created by paul on 18/07/2023.
//

import Foundation

// MARK: - GetPlaylistsResponse
struct GetPlaylistsResponse: Codable {
	let subsonicResponse: SubsonicResponse

	enum CodingKeys: String, CodingKey {
		case subsonicResponse = "subsonic-response"
	}
	
	// MARK: - SubsonicResponse
	struct SubsonicResponse: Codable {
		let status: String
		let playlists: Playlists
		let serverVersion, type, version: String
	}

	// MARK: - Playlists
	struct Playlists: Codable {
		let playlist: [Playlist]
	}

	// MARK: - Playlist
	struct Playlist: Codable, Hashable {
		let playlistPublic: Bool
		let owner, id, coverArt: String
		let duration, songCount: Int
		let created, comment, name, changed: String

		enum CodingKeys: String, CodingKey {
			case playlistPublic = "public"
			case owner, id, coverArt, duration, songCount, created, comment, name, changed
		}
	}
}




