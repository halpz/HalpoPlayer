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
	@EnvironmentObject var database: Database
	var body: some View {
		if let playlists = database.playlists {
			List {
				ForEach(playlists.subsonicResponse.playlists.playlist, id: \.self) { playlist in
					Button {
						viewModel.goToPlaylist(playlist: playlist, coordinator: coordinator)
					} label: {
						PlaylistCell(playlist: playlist)
					}
					.listRowSeparator(.hidden)
				}
			}
			.listStyle(.plain)
			.navigationTitle("Playlists")
		} else {
			ProgressView()
				.onAppear {
					if database.playlists == nil {
						viewModel.getPlaylists()
					}
				}
		}
	}
}


