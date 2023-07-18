//
//  ContentViewModel.swift
//  HalpoPlayer
//
//  Created by paul on 18/07/2023.
//

import Foundation
import UIKit

class ContentViewModel: ObservableObject {
	@Published var searchText: String
	var player = AudioManager.shared
	var database = Database.shared
	var results: [GetAlbumListResponse.Album] {
		if searchText.isEmpty {
			return database.albums
		} else {
			return database.albums.filter {
				$0.title.localizedCaseInsensitiveContains(searchText) ||
				$0.artist.localizedCaseInsensitiveContains(searchText)
			}
		}
	}
	init() {
		searchText = ""
	}
	func albumTapped(albumId: String, coordinator: Coordinator) {
		coordinator.albumTapped(albumId: albumId)
	}
	func refresh() {
		Task {
			do {
				let albums = try await SubsonicClient.shared.getAlbumList()
				self.database.albums = albums.subsonicResponse.albumList.album
			} catch {
				if try await SubsonicClient.shared.authenticate() {
					let albums = try await SubsonicClient.shared.getAlbumList()
					self.database.albums = albums.subsonicResponse.albumList.album
				}
			}
		}
	}
	func shuffle() {
		Task {
			let response = try await SubsonicClient.shared.getRandomSongs()
			let songs = response.subsonicResponse.randomSongs.song.compactMap {
				return Song(randomSong: $0)
			}
			player.play(songs:songs, index: 0)
		}
	}
	func goToLogin(coordinator: Coordinator) {
		coordinator.goToLogin()
	}
}
