//
//  SubsonicAPI.swift
//  halpoplayer
//
//  Created by paul on 13/07/2023.
//

import Foundation

enum SubsonicAPI {
	case authenticate
	case getAlbumList
	case getAlbum(id: String)
	case randomSongs(albumId: String?)
	case search(term: String)
	case getIndexes
	case coverArt(albumId: String)
	case stream(id: String, mp3: Bool)
	case getSimilarSongs(id: String)
	case getPlaylists
	
	var method: String {
		"GET"
	}
	
	var pathComponent: String {
		switch self {
		case .authenticate:
			return "ping.view?"
		case .getAlbumList:
			return "getAlbumList?type=newest&size=500"
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
		}
	}
}
