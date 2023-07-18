//
//  PlaylistsView.swift
//  HalpoPlayer
//
//  Created by paul on 18/07/2023.
//

import SwiftUI

struct PlaylistsView: View {
	@StateObject var viewModel = PlaylistsViewModel()
	@EnvironmentObject var coordinator: Coordinator
	var body: some View {
		
		if let playlists = viewModel.playlists {
			List {
				ForEach(playlists.subsonicResponse.playlists.playlist, id: \.self) { playlist in
					Button {
						viewModel.goToPlaylist(playlist: playlist, coordinator: coordinator)
					} label: {
						Text(playlist.name)
					}
				}
			}
		} else {
			ProgressView()
				.onAppear {
					viewModel.getPlaylists()
				}
		}
	}
}

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
		coordinator.goToPlaylist(id: playlist.id)
	}
}
