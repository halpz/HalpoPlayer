//
//  AlbumDetailViewModel.swift
//  HalpoPlayer
//
//  Created by paul on 18/07/2023.
//

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
			if let scrollToSong = scrollToSong {
				DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
					self.scrollToSong = scrollToSong
				}
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
				if self.database.musicCache[$0.id] == nil {
					self.downloading[$0.id] = true
				}
			}
		}
		for song in songs where self.database.musicCache[song.id] == nil {
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
	func addSongToPlaylist(song: Song, coordinator: Coordinator) {
		coordinator.selectPlaylist(songs: [song])
	}
	func addAlbumToPlaylist(album: Album, coordinator: Coordinator) {
		if let songs = albumResponse?.subsonicResponse.album.song {
		    coordinator.selectPlaylist(songs: songs)
		}
	}
	func goToArtist(_ coordinator: Coordinator) {
		if let artistId = self.albumResponse?.subsonicResponse.album.artistId,
		   let artistName = self.albumResponse?.subsonicResponse.album.artist {
			coordinator.goToArtist(artistId: artistId, artistName: artistName)
		}
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
