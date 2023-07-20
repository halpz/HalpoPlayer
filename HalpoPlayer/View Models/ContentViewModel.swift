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
	@Published var viewType = Database.shared.libraryViewType
	var player = AudioManager.shared
	var database = Database.shared
	var results: [GetAlbumListResponse.Album] {
		if searchText.isEmpty {
			return database.albumList ?? []
		} else {
			return database.albumList?.filter {
				$0.title.localizedCaseInsensitiveContains(searchText) ||
				$0.artist.localizedCaseInsensitiveContains(searchText)
			} ?? []
		}
	}
	init() {
		searchText = ""
		if database.albumList == nil {
			getAlbumList()
		}
		NotificationCenter.default.addObserver(self, selector: #selector(getAlbumList), name: Notification.Name("login"), object: nil)
	}
	@objc func getAlbumList() {
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
	func albumTapped(albumId: String, coordinator: Coordinator) {
		coordinator.albumTapped(albumId: albumId, scrollToSong: nil)
	}
	func refresh() {
		getAlbumList()
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
