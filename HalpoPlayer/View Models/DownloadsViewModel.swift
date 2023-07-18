//
//  DownloadsViewModel.swift
//  HalpoPlayer
//
//  Created by paul on 18/07/2023.
//

import Foundation

class DownloadsViewModel: ObservableObject {
	@Published var showAlert: Bool
	@Published var downloadsType: DownloadsType
	@Published var searchText: String
	var database = Database.shared
	init() {
		showAlert = false
		downloadsType = .songs
		searchText = ""
	}
	var downloads: [CachedSong] {
		var sortedSongs = database.musicCache.map {$1}.sorted { ($0.song.track ?? 0) < ($1.song.track ?? 0) }
		sortedSongs = sortedSongs.sorted { $0.album.name < $1.album.name }
		if !searchText.isEmpty {
			sortedSongs = sortedSongs.filter {
				$0.song.title.localizedCaseInsensitiveContains(searchText) ||
				$0.song.artist.localizedCaseInsensitiveContains(searchText)
			}
		}
		return sortedSongs
	}
	var albums: [Album] {
		var albumsDict = [String: Album]()
		for (_, value) in database.musicCache {
			albumsDict[value.album.id] = value.album
		}
		var sortedAlbums = albumsDict.map {$1}.sorted { $0.name < $1.name }
		if !searchText.isEmpty {
			sortedAlbums = sortedAlbums.filter {
				$0.name.localizedCaseInsensitiveContains(searchText)
			}
		}
		return sortedAlbums
	}
	func playSong(file: CachedSong) {
		if let index = downloads.firstIndex(of: file) {
			AudioManager.shared.play(songs: downloads.map {$0.song}, index: index)
		} else {
			print("not found")
		}
	}
	func deleteSong(file: CachedSong) {
		database.deleteSong(song: file.song)
	}
	func addSongToQueue(file: CachedSong) {
		AudioManager.shared.addSongToQueue(song: file.song)
	}
	func albumTapped(album: Album, coordinator: Coordinator) {
		if SubsonicClient.shared.currentAddress == nil {
			coordinator.albumTappedOffline(album: album)
		} else {
			coordinator.albumTapped( albumId: album.id)
		}
	}
	func shuffle() {
		let shuffled = downloads.map {
			$0.song
		}.shuffled()
		AudioManager.shared.play(songs: shuffled, index: 0)
	}
	func deleteAll() {
		for download in downloads {
			database.deleteSong(song: download.song)
		}
	}
}
