//
//  PlaylistsViewModel.swift
//  HalpoPlayer
//
//  Created by paul on 18/07/2023.
//

import Foundation

class PlaylistsViewModel: ObservableObject {
	@Published var playlists: GetPlaylistsResponse?
	func getPlaylists() {
		Task {
			do {
				let response = try await SubsonicClient.shared.getPlaylists()
				DispatchQueue.main.async {
					self.playlists = response
				}
			} catch {
				print(error)
			}
		}
	}
	func goToPlaylist(playlist: GetPlaylistsResponse.Playlist, coordinator: Coordinator) {
		coordinator.goToPlaylist(playlist: playlist)
	}
}
