//
//  LibraryViewModel.swift
//  HalpoPlayer
//
//  Created by paul on 18/07/2023.
//

import Foundation
import UIKit

class LibraryViewModel: ObservableObject {
	@Published var searchText: String
	@Published var viewType = Database.shared.libraryViewType
	var player = AudioManager.shared
	var database = Database.shared
	var albums: [GetAlbumListResponse.Album] {
		if searchText.isEmpty {
			return database.albumList ?? []
		} else {
			return database.albumList?.filter {
				$0.title.localizedCaseInsensitiveContains(searchText) ||
				$0.artist.localizedCaseInsensitiveContains(searchText)
			} ?? []
		}
	}
	var artists: [GetIndexesResponse.Artist] {
		if searchText.isEmpty {
			return database.artistList ?? []
		} else {
			return database.artistList?.filter {
				$0.name.localizedCaseInsensitiveContains(searchText)
			} ?? []
		}
	}
	init() {
		searchText = ""
		loadContent()
		NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name("login"), object: nil)
	}
	func loadContent() {
		switch viewType {
		case .albums:
			if database.albumList == nil {
				getAlbumList()
			}
		case .artists:
			getArtists()
		}
	}
	func getAlbumList() {
		Task {
			do {
				if try await SubsonicClient.shared.authenticate() {
					let response = try await SubsonicClient.shared.getAlbumList()
					DispatchQueue.main.async {
						self.database.albumList = response.subsonicResponse.albumList.album
					}
				}
			} catch {
				print(error)
			}
		}
	}
	func getArtists() {
		Task {
			do {
				if try await SubsonicClient.shared.authenticate() {
					let response = try await SubsonicClient.shared.getIndexes()
					let artists: [GetIndexesResponse.Artist] = response.subsonicResponse.indexes.index.flatMap { index in
						return index.artist
					}
					DispatchQueue.main.async {
						self.database.artistList = artists
					}
				}
			} catch {
				print(error)
			}
		}
	}
	func albumTapped(albumId: String, coordinator: Coordinator) {
		coordinator.albumTapped(albumId: albumId, scrollToSong: nil)
	}
	@objc func refresh() {
		loadContent()
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
