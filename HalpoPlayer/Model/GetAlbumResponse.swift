//
//  GetAlbumResponse.swift
//  halpoplayer
//
//  Created by paul on 07/07/2023.
//

import Foundation

// MARK: - GetAlbumResponse
struct GetAlbumResponse: Codable {
	let subsonicResponse: SubsonicResponse
	
	enum CodingKeys: String, CodingKey {
		case subsonicResponse = "subsonic-response"
	}
	
	// MARK: - SubsonicResponse
	struct SubsonicResponse: Codable {
		let status, serverVersion, type: String
		let album: Album
		let version: String
	}
}

// MARK: - Album
struct Album: Codable, Identifiable, Hashable {
	let artist, artistId: String?
	let id, coverArt: String
	let duration, songCount: Int
	let created: String
	let year: Int?
	let name: String
	let song: [Song]
	
	init(searchResponse: Search2Response.Album) {
		artist = searchResponse.artist
		artistId = searchResponse.artistId
		id = searchResponse.id
		coverArt = searchResponse.coverArt
		duration = searchResponse.duration
		songCount = searchResponse.songCount
		created = searchResponse.created
		year = searchResponse.year
		name = searchResponse.name
		song = []
	}
}


// MARK: - Song
struct Song: Codable, Identifiable, Hashable {
	let suffix, title: String
	let bitRate: Int
	let isVideo: Bool
	let duration: Int
	let path: String
	let artistId: String?
	let year: Int?
	let parent: String
	let size: Int
	let track: Int?
	let albumId, id, type, artist: String
	let contentType: String
	let isDir: Bool
	let album, coverArt, created: String
	
	init(randomSong: GetRandomSongsResponse.Song) {
		self.suffix = randomSong.suffix
		title = randomSong.title
		bitRate = randomSong.bitRate
		isVideo = randomSong.isVideo
		duration = randomSong.duration
		path = randomSong.path
		artistId = randomSong.artistId
		year = randomSong.year
		parent = randomSong.parent
		size = randomSong.size
		track = randomSong.track
		albumId = randomSong.albumId
		id = randomSong.id
		type = randomSong.type
		artist = randomSong.artist
		contentType = randomSong.contentType
		isDir = randomSong.isDir
		album = randomSong.album
		coverArt = randomSong.coverArt
		created = randomSong.created
	}
	
	init(searchSong: Search2Response.Song) {
		self.suffix = searchSong.suffix
		title = searchSong.title
		bitRate = searchSong.bitRate
		isVideo = searchSong.isVideo
		duration = searchSong.duration
		path = searchSong.path
		artistId = searchSong.artistId
		year = searchSong.year
		parent = searchSong.parent
		size = searchSong.size
		track = searchSong.track
		albumId = searchSong.albumId
		id = searchSong.id
		type = searchSong.type
		artist = searchSong.artist
		contentType = searchSong.contentType
		isDir = searchSong.isDir
		album = searchSong.album
		coverArt = searchSong.coverArt
		created = searchSong.created
	}
}
