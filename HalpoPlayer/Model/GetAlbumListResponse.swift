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
		let duration: Int?
		let artistId, artist: String
		let isDir: Bool
		let name: String
		let playCount: Int?
		let played, genre: String?
	}
}

enum AlbumSortType: String, CaseIterable, Codable {
	case newest
	case alphabeticalByName
	case alphabeticalByArtist
	case recent
	case frequent
	case random
	var title: String {
		switch self {
		case .newest:
			return "Newest"
		case .alphabeticalByName:
			return "Alphabetical (name)"
		case .alphabeticalByArtist:
			return "Alphabetical (artist)"
		case .recent:
			return "Recently Played"
		case .frequent:
			return "Frequently played"
		case .random:
			return "Random"
		}
	}
}
