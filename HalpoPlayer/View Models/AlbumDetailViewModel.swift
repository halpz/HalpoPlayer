//
//  AlbumDetailViewModel.swift
//  HalpoPlayer
//
//  Created by paul on 18/07/2023.
//

import Foundation
import UIKit

class AlbumDetailViewModel: ObservableObject {
	let albumId: String
	var player = AudioManager.shared
	var database = Database.shared
	@Published var albumResponse: GetAlbumResponse?
	@Published var image: UIImage?
	@Published var downloading = [String: Bool]()
	var playButtonName: String {
		if let currentSong = player.currentSong,
		   let songs = albumResponse?.subsonicResponse.album.song,
		   player.isPlaying && songs.contains(currentSong) {
			return "pause.circle.fill"
		} else {
			return "play.circle.fill"
		}
	}
	init(albumId: String) {
		self.albumId = albumId
	}
	func shuffleSongs(songs: [Song]) {
		let shuffled = songs.shuffled()
		player.play(songs:shuffled, index: 0)
	}
	func downloadAll(songs: [Song]) {
		DispatchQueue.main.async {
			songs.forEach {
				self.downloading[$0.id] = true
			}
			songs.forEach {
				self.database.deleteSong(song: $0)
			}
		}
		for song in songs {
			self.database.cacheSong(song: song) {
				DispatchQueue.main.async {
					self.downloading[song.id] = false
				}
			}
		}
	}
	func playSong(song: Song, songs: [Song]) {
		if let index = songs.firstIndex(of: song) {
			self.player.play(songs: songs, index: index)
		}
	}
	func addSongToQueue(song: Song) {
		self.player.addSongToQueue(song: song)
	}
	func downloadSong(song: Song) {
		DispatchQueue.main.async {
			self.downloading[song.id] = true
		}
		self.database.cacheSong(song: song) {
			DispatchQueue.main.async {
				self.downloading[song.id] = false
			}
		}
	}
	func deleteSong(song: Song) {
		self.database.deleteSong(song: song)
	}
	func deleteAlbumFromCache() {
		for song in albumResponse?.subsonicResponse.album.song ?? [] where database.musicCache[song.id] != nil {
			database.deleteSong(song: song)
		}
	}
	func getAlbum() {
		Task {
			do {
				let album = try await SubsonicClient.shared.getAlbum(id: albumId)
				let imageResponse = try await SubsonicClient.shared.coverArt(albumId: albumId)
				DispatchQueue.main.async {
					self.image = imageResponse
					self.albumResponse = album
				}
			} catch {
				print(error)
			}
		}
	}
	func playButtonPressed() {
		if let currentSong = player.currentSong,
		   let songs = albumResponse?.subsonicResponse.album.song,
		   player.isPlaying && songs.contains(currentSong) {
			self.player.queue.pause()
		} else {
			if let songs = albumResponse?.subsonicResponse.album.song {
				if self.player.songs == songs {
					self.player.queue.play()
				} else {
					self.player.play(songs: songs, index: 0)
				}
			}
		}
	}
}
