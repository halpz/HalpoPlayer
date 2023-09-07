//
//  LibraryViewModel.swift
//  HalpoPlayer
//
//  Created by paul on 18/07/2023.
//

import UIKit

class LibraryViewModel: ObservableObject {
	@Published var loggedIn = false
	@Published var searchText: String
	@Published var viewType = Database.shared.libraryViewType
	var player = AudioManager.shared
	@Published var albums: [GetAlbumListResponse.Album] = []
	@Published var artists: [GetArtistsResponse.Artist] = []
	var albumPage: Int = 0
	var currentTask: Task<(), Error>?
	var filteredAlbums: [GetAlbumListResponse.Album] {
		if searchText.isEmpty {
			return albums
		} else {
			return albums.filter {
				$0.title.localizedCaseInsensitiveContains(searchText) ||
				$0.artist.localizedCaseInsensitiveContains(searchText)
			}
		}
	}
	var filteredArtists: [GetArtistsResponse.Artist] {
		if searchText.isEmpty {
			return artists
		} else {
			return artists.filter {
				$0.name.localizedCaseInsensitiveContains(searchText)
			}
		}
	}
	init() {
		searchText = ""
		self.artists = Database.shared.artistList ?? []
		self.albums = Database.shared.albumList ?? []
		self.albumPage = Database.shared.albumPage
		self.currentTask?.cancel()
		self.currentTask = Task {
			do {
				try await loadContent(force: true)
			} catch {
				print(error)
			}
			await MainActor.run {
				AudioManager.shared.loadSavedState()
			}
		}
		NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name("login"), object: nil)
	}
	func loadContent(force: Bool = false) async throws {
		switch viewType {
		case .albums:
			if albums.isEmpty || force {
				self.albumPage = 0
				try await getAlbumList()
			}
		case .artists:
			try await getArtists()
		}
	}
	func getAlbumList() async throws {
		let response = try await SubsonicClient.shared.getAlbumList(page: albumPage)
		let newAlbums: [GetAlbumListResponse.Album]
		if self.albumPage == 0 {
			await MainActor.run {
				self.albums = []
			}
			newAlbums = response.subsonicResponse.albumList.album
		} else {
			newAlbums = self.albums + response.subsonicResponse.albumList.album
		}
		self.albumPage += 1
		Database.shared.albumPage = self.albumPage
		await MainActor.run {
			self.albums = newAlbums
			Database.shared.albumList = self.albums
		}
	}
	func getArtists() async throws {
		let response = try await SubsonicClient.shared.getArtists()
		let artistsResponse: [GetArtistsResponse.Artist] = response.subsonicResponse.artists.index.flatMap { index in
			return index.artist
		}
		Database.shared.artistList = artistsResponse
		await MainActor.run {
			self.artists = artistsResponse
		}
	}
	func albumAppeared(album: GetAlbumListResponse.Album) {
		if album == self.albums.last {
			self.currentTask?.cancel()
			self.currentTask = Task {
				do {
					try await self.getAlbumList()
				} catch {
					print(error)
				}
			}
		}
	}
	func albumTapped(albumId: String, coordinator: Coordinator) {
		coordinator.albumTapped(albumId: albumId, scrollToSong: nil)
	}
	@objc func refresh() {
		self.currentTask?.cancel()
		self.currentTask = Task {
			do {
				try await loadContent(force: true)
			} catch {
				print(error)
			}
		}
	}
	func shuffle() {
		Task {
			let response = try await SubsonicClient.shared.getRandomSongs()
			let songs = response.subsonicResponse.randomSongs.song.compactMap {
				return Song(randomSong: $0)
			}
			DispatchQueue.main.async {
				self.player.play(songs:songs, index: 0)
			}
		}
	}
	func goToLogin(coordinator: Coordinator) {
		coordinator.goToLogin()
	}
}
