//
//  CreatePlaylistResponse.swift
//  HalpoPlayer
//
//  Created by paul on 01/08/2023.
//

import Foundation

// MARK: - CreatePlaylistResponse
struct CreatePlaylistResponse: Codable {
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
		let owner, id, coverArt: String
		let duration, songCount: Int
		let created, changed, name: String

		enum CodingKeys: String, CodingKey {
			case playlistPublic = "public"
			case owner, id, coverArt, duration, songCount, created, changed, name
		}
	}
}


