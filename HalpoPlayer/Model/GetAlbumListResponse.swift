//
//  GetAlbumListResponse.swift
//  halpoplayer
//
//  Created by paul on 07/07/2023.
//

import Foundation

// MARK: - GetAlbumListResponse
struct GetAlbumListResponse: Codable {
	let subsonicResponse: SubsonicResponse
	
	enum CodingKeys: String, CodingKey {
		case subsonicResponse = "subsonic-response"
	}
	
	// MARK: - SubsonicResponse
	struct SubsonicResponse: Codable {
		let status, serverVersion, type: String
		let albumList: AlbumList
		let version: String
	}
	
	// MARK: - AlbumList
	struct AlbumList: Codable {
		let album: [Album]
	}
	
	// MARK: - Album
	struct Album: Codable, Hashable, Identifiable {
		let id, album, parent: String
		let isVideo: Bool
		let title, coverArt: String
		let songCount: Int
		let year: Int?
		let created: String
		let duration: Int
		let artistId, artist: String
		let isDir: Bool
		let name: String
		let playCount: Int?
		let played, genre: String?
	}
}
