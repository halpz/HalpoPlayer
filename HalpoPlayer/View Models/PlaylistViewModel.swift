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
	var reordering = false
	@Published var image: UIImage?
	@Published var playlistResponse: GetPlaylistResponse?
	init(id: String) {
		playlistId = id
		Task {
			do {
				try await getPlaylist()
			} catch {
				print(error)
			}
		}
		
	}
	var playButtonName: String {
		if player.isPlaying && player.songs == songs {
			return "pause.fill"
		} else {
			return "play.fill"
		}
	}
	var songs: [Song] {
		return playlistResponse?.subsonicResponse.playlist.entry?.map {
			Song(playlistEntry: $0)
		} ?? []
	}
	func getPlaylist() async throws {
				let response = try await SubsonicClient.shared.getPlaylist(id: playlistId)
				let imageResponse = try await SubsonicClient.shared.coverArt(albumId: response.subsonicResponse.playlist.coverArt)
				DispatchQueue.main.async {
					self.playlistResponse = response
					self.image = imageResponse
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
	func move(from source: IndexSet, to destination: Int) {
		guard !reordering else { return }
		reordering = true
		guard let from = source.first else {return}
		var songList = songs
		let song = songList.remove(at: from)
		var finalDestination: Int = 0
		if from > destination {
			finalDestination = destination
		} else {
			finalDestination = destination-1
		}
		songList.insert(song, at: finalDestination)
		let finalSongs = songList
		Task {
			do {
				_ = try await SubsonicClient.shared.updatePlaylist(id: self.playlistId , songs: finalSongs)
				let response = try await SubsonicClient.shared.getPlaylist(id: self.playlistId)
				DispatchQueue.main.async {
					self.playlistResponse = response
				}
				self.reordering = false
			} catch {
				print(error)
				do {
					try await getPlaylist()
					self.reordering = false
				} catch {
					print(error)
					self.reordering = false
				}
			}
		}
	}
	func shuffle() {
		let songs = self.songs.shuffled()
		self.player.play(songs: songs, index: 0)
	}
}
