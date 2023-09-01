//
//  SubsonicAPI.swift
//  halpoplayer
//
//  Created by paul on 13/07/2023.
//

import Foundation

enum SubsonicAPI {
	case authenticate
	case getAlbumList(page: Int)
	case getAlbum(id: String)
	case randomSongs(albumId: String?)
	case search(term: String)
	case getIndexes
	case coverArt(albumId: String)
	case stream(id: String, mp3: Bool)
	case getSimilarSongs(id: String)
	case getPlaylists
	case getPlaylist(id: String)
	case updatePlaylist(id: String, songs: [Song])
	case addSongToPlaylist(playlistId: String, songId: String)
	case getArtists
	case getArtist(id: String)
	case getArtistInfo(id: String)
	case createPlaylist(name: String)
	
	var method: String {
		"GET"
	}
	
	var pathComponent: String {
		switch self {
		case .authenticate:
			return "ping.view?"
		case .getAlbumList(let page):
			let pageSize = 12
			let offset = pageSize * page
			return "getAlbumList?type=newest&size=\(pageSize)&offset=\(offset)"
		case .getAlbum(let id):
			return "getAlbum?id=\(id)"
		case .randomSongs(let albumId):
			if let albumId = albumId {
				return "getRandomSongs?size=500&musicFolderId=\(albumId)"
			} else {
				return "getRandomSongs?size=500"
			}
		case .search(let term):
			return "search2?query=\(term)"
		case .getIndexes:
			return "getIndexes?"
		case .coverArt(let albumId):
			return "getCoverArt?id=\(albumId)&size=500"
		case .stream(let id, let mp3):
			let format = mp3 ? "&format=mp3" : "&format=raw"
			return "stream?id=\(id)\(format)"
		case .getSimilarSongs(let id):
			return "getSimilarSongs?id=\(id)"
		case .getPlaylists:
			return "getPlaylists?"
		case .getPlaylist(let id):
			return "getPlaylist?id=\(id)"
		case .updatePlaylist(let id, let songs):
			var newIds: String = ""
			var removalIndices: String = ""
			for (index, song) in songs.enumerated() {
				newIds.append("&songIdToAdd=\(song.id)")
				removalIndices.append("&songIndexToRemove=\(index)")
			}
			return "updatePlaylist?playlistId=\(id)\(removalIndices)\(newIds)"
		case .addSongToPlaylist(let playlistId, let songId):
			return "updatePlaylist?playlistId=\(playlistId)&songIdToAdd=\(songId)"
		case .getArtists:
			return "getArtists?"
		case .getArtist(let id):
			return "getArtist?id=\(id)"
		case .getArtistInfo(let id):
			return "getArtistInfo?id=\(id)"
		case .createPlaylist(let name):
			return "createPlaylist?name=\(name)"
		}
	}
}
