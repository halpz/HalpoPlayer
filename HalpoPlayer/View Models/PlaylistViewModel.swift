//
//  PlaylistViewModel.swift
//  HalpoPlayer
//
//  Created by paul on 18/07/2023.
//

import UIKit

class PlaylistViewModel: ObservableObject {
	var playlistId: String
	var player = AudioManager.shared
	@Published var image: UIImage?
	@Published var playlistResponse: GetPlaylistResponse?
	init(id: String) {
		playlistId = id
	}
	var playButtonName: String {
		if player.isPlaying && player.songs == songs {
			return "pause.fill"
		} else {
			return "play.fill"
		}
	}
	var songs: [Song] {
		return playlistResponse?.subsonicResponse.playlist.entry.map {
			Song(playlistEntry: $0)
		} ?? []
	}
	func getPlaylist() {
		Task {
			let response = try await SubsonicClient.shared.getPlaylist(id: playlistId)
			let imageResponse = try await SubsonicClient.shared.coverArt(albumId: response.subsonicResponse.playlist.coverArt)
			DispatchQueue.main.async {
				self.playlistResponse = response
				self.image = imageResponse
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
		if player.songs == songs {
			if player.isPlaying {
				self.player.queue.pause()
			} else {
				self.player.queue.play()
			}
		} else {
			self.player.play(songs: songs, index: 0)
		}
	}
	func cellDidAppear(song: Song) {
		guard MediaControlBarMinimized.shared.isCompact == false else { return }
		MediaControlBarMinimized.shared.isCompact = true
	}
}
