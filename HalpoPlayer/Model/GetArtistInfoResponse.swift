//
//  GetArtistInfoResponse.swift
//  HalpoPlayer
//
//  Created by paul on 20/07/2023.
//

import Foundation

// MARK: - GetArtistInfoResponse
struct GetArtistInfoResponse: Codable {
	let subsonicResponse: SubsonicResponse

	enum CodingKeys: String, CodingKey {
		case subsonicResponse = "subsonic-response"
	}
	
	// MARK: - SubsonicResponse
	struct SubsonicResponse: Codable {
		let status, serverVersion, type: String
		let artistInfo: ArtistInfo
		let version: String
	}

	// MARK: - ArtistInfo
	struct ArtistInfo: Codable {
		let largeImageUrl, mediumImageUrl, smallImageUrl: String
		let similarArtist: [SimilarArtist]?
		let lastFmUrl: String
		let biography: String?
		let musicBrainzId: String?
	}

	// MARK: - SimilarArtist
	struct SimilarArtist: Codable {
		let albumCount: Int
		let id, name, coverArt: String
		let artistImageUrl: String
	}
}


