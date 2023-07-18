//
//  PlaylistViewModel.swift
//  HalpoPlayer
//
//  Created by paul on 18/07/2023.
//

import Foundation

class PlaylistViewModel: ObservableObject {
	var playlistId: String
	var player = AudioManager.shared
	@Published var playlistResponse: GetPlaylistResponse?
	init(id: String) {
		playlistId = id
	}
	var songs: [Song] {
		return playlistResponse?.subsonicResponse.playlist.entry.map {
			Song(playlistEntry: $0)
		} ?? []
	}
	func getPlaylist() {
		Task {
			let response = try await SubsonicClient.shared.getPlaylist(id: playlistId)
			DispatchQueue.main.async {
				self.playlistResponse = response
			}
		}
	}
	func playSong(song: Song) {
		if let index = songs.firstIndex(of: song) {
			self.player.play(songs: songs, index: index)
		}
	}
	func playPlaylist() {
		guard !songs.isEmpty else {return}
		self.player.play(songs: songs, index: 0)
	}
}
