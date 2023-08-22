//
//  PlaylistsViewModel.swift
//  HalpoPlayer
//
//  Created by paul on 18/07/2023.
//

import Foundation

class PlaylistsViewModel: ObservableObject {
	var song: Song?
	var database = Database.shared
	@Published var loading = true
	@Published var showPrompt = false
	@Published var playlistName: String = ""
	init(_ song: Song? = nil, refresh: Bool = false) {
		self.song = song
		if database.playlists == nil || refresh {
			Task {
				do {
					try await self.getPlaylists()
				} catch {
					print(error)
				}
			}
		} else {
			loading = false
		}
	}
	func getPlaylists() async throws {
		let response = try await SubsonicClient.shared.getPlaylists()
		DispatchQueue.main.async {
			self.loading = false
			self.database.playlists = response
		}
	}
	func goToPlaylist(playlist: GetPlaylistsResponse.Playlist, coordinator: Coordinator) {
		coordinator.goToPlaylist(playlist: playlist)
	}
	func cellDidAppear(playlist: GetPlaylistsResponse.Playlist) {
		guard MediaControlBarMinimized.shared.isCompact == false else { return }
		MediaControlBarMinimized.shared.isCompact = true
	}
	func addSongToPlaylist(playlistId: String, coordinator: Coordinator) {
		Task {
			guard let songId = song?.id else { return }
			_ = try await SubsonicClient.shared.addSongToPlaylist(playlistId: playlistId, songId: songId)
			DispatchQueue.main.async {
				coordinator.path.removeLast()
			}
		}
	}
	func createPlaylist(name: String) {
		Task {
			do {
				let response = try await SubsonicClient.shared.createPlaylist(name: name)
				print(response)
				try await getPlaylists()
			} catch {
				print(error)
			}
		}
	}
}
