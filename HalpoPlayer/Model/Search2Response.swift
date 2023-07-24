//
//  Search2Response.swift
//  halpoplayer
//
//  Created by paul on 10/07/2023.
//

import Foundation

// MARK: - Search2Response
struct Search2Response: Codable {
	let subsonicResponse: SubsonicResponse
	
	enum CodingKeys: String, CodingKey {
		case subsonicResponse = "subsonic-response"
	}
	
	// MARK: - SubsonicResponse
	struct SubsonicResponse: Codable {
		let status, serverVersion, type: String
		let searchResult2: SearchResult2
		let version: String
	}
	
	// MARK: - SearchResult2
	struct SearchResult2: Codable {
		let album: [Album]?
		let song: [Song]?
		let artist: [Artist]?
	}
	
	// MARK: - Album
	struct Album: Codable, Identifiable, Hashable {
		let id, album, parent: String
		let isVideo: Bool
		let title, coverArt: String
		let songCount: Int
		let year: Int?
		let created: String
		let duration: Int?
		let artistId, artist: String?
		let isDir: Bool
		let name: String
		let genre: String?
	}
	
	// MARK: - Artist
	struct Artist: Codable {
		let albumCount: Int
		let id, name, coverArt: String
		let artistImageUrl: String
	}
	
	// MARK: - Song
	struct Song: Codable, Identifiable {
		let artistId: String?
		let id, album, suffix: String
		let parent, contentType, path, title: String
		let coverArt: String
		let size: Int
		let type: String
		let isVideo: Bool
		let year: Int?
		let created: String
		let duration: Int?
		let albumId, artist: String
		let isDir: Bool
		let bitRate: Int?
		let track, discNumber: Int?
		let genre: String?
	}
}


