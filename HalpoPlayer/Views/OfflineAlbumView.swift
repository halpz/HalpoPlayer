//
//  OfflineAlbumView.swift
//  HalpoPlayer
//
//  Created by paul on 17/07/2023.
//

import SwiftUI

struct OfflineAlbumView: View {
	@EnvironmentObject var database: Database
	let album: Album
	var songs: [CachedSong] {
		var tempSongs = [CachedSong]()
		for (_, value) in database.musicCache where value.album.id == album.id {
			tempSongs.append(value)
		}
		tempSongs = tempSongs.sorted {
			($0.song.track ?? 0) < ($1.song.track ?? 0)
		}
		return tempSongs
	}
	var body: some View {
		List {
			ForEach(songs) { file in
				Button {
					if let index = songs.firstIndex(of: file) {
						AudioManager.shared.play(songs: songs.map {$0.song}, index: index)
					} else {
						print("not found")
					}
				} label: {
					SongCell(showAlbumName: false, showTrackNumber: true, song: file.song)
				}
				.swipeActions {
					Button(role: .destructive) {
						self.database.deleteSong(song: file.song)
					} label: {
						Image(systemName: "trash.fill").imageScale(.large)
					}
					Button {
						AudioManager.shared.addSongToQueue(song: file.song)
					} label: {
						Image(systemName: "text.badge.plus").imageScale(.large)
					}
					.tint(.blue)
				}
			}
		}
		.listStyle(.plain)
		.navigationTitle(album.name)
	}
}
