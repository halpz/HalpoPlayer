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
	init(_ song: Song? = nil) {
		self.song = song
		if database.playlists == nil {
			getPlaylists()
		}
	}
	func getPlaylists() {
		Task {
			do {
				let response = try await SubsonicClient.shared.getPlaylists()
				DispatchQueue.main.async {
					self.database.playlists = response
				}
			} catch {
				print(error)
			}
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
}
