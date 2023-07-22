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
	@Published var scrollToSong: String?
	var playButtonName: String {
		if let currentSong = player.currentSong,
		   let songs = albumResponse?.subsonicResponse.album.song,
		   player.isPlaying && songs.contains(currentSong) {
			return "pause.circle.fill"
		} else {
			return "play.circle.fill"
		}
	}
	init(albumId: String, scrollToSong: String?) {
		self.albumId = albumId
		getAlbum() {
			guard let scrollToSong = scrollToSong else {return}
			DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
				self.scrollToSong = scrollToSong
			}
		}
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
		database.downloadedAlbums[albumId] = true
	}
	func playSong(song: Song, songs: [Song]) {
		if let index = songs.firstIndex(of: song) {
			self.player.play(songs: songs, index: index)
		}
	}
	func addSongToQueue(song: Song) {
		self.player.addSongToQueue(song: song)
	}
	func addSongToPlaylist(song: Song, coordinator: Coordinator) {
		coordinator.selectPlaylist(song: song)
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
		database.downloadedAlbums[albumId] = false
	}
	func getAlbum(callback: (() -> Void)? = nil) {
		Task {
			do {
				let album = try await SubsonicClient.shared.getAlbum(id: albumId)
				let imageResponse = try await SubsonicClient.shared.coverArt(albumId: albumId)
				DispatchQueue.main.async {
					self.image = imageResponse
					self.albumResponse = album
					callback?()
				}
			} catch {
				print(error)
			}
		}
	}
	func isAlbumDownloaded() {
		guard let songs = albumResponse?.subsonicResponse.album.song else {
			database.downloadedAlbums[albumId] = false
			return
		}
		var downloaded = true
		for song in songs {
			if database.musicCache[song.id] == nil {
				downloaded = false
			}
		}
		database.downloadedAlbums[albumId] = downloaded
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
