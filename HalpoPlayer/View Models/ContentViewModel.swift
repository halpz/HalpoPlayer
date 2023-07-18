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
	@Published var albumList: [GetAlbumListResponse.Album]?
	var player = AudioManager.shared
	var database = Database.shared
	var results: [GetAlbumListResponse.Album] {
		if searchText.isEmpty {
			return albumList ?? []
		} else {
			return albumList?.filter {
				$0.title.localizedCaseInsensitiveContains(searchText) ||
				$0.artist.localizedCaseInsensitiveContains(searchText)
			} ?? []
		}
	}
	init() {
		searchText = ""
	}
	func getAlbumList() {
		Task {
			do {
				if try await SubsonicClient.shared.authenticate() {
					let response = try await SubsonicClient.shared.getAlbumList()
					DispatchQueue.main.async {
						self.albumList = response.subsonicResponse.albumList.album
					}
				}
			} catch {
				print(error)
			}
		}
	}
	func albumTapped(albumId: String, coordinator: Coordinator) {
		coordinator.albumTapped(albumId: albumId)
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
			player.play(songs:songs, index: 0)
		}
	}
	func goToLogin(coordinator: Coordinator) {
		coordinator.goToLogin()
	}
}
