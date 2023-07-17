//
//  CachedSong.swift
//  halpoplayer
//
//  Created by paul on 13/07/2023.
//

import Foundation

struct CachedSong: Codable, Identifiable, Equatable {
	var id: String {
		song.id
	}
	let song: Song
	let album: Album
	let imageUrl: URL
	let path: String
}
