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
						PlaylistCell(playlist: playlist)
					}
				}
			}
			.listStyle(.plain)
			.navigationTitle("Playlists")
		} else {
			ProgressView()
				.onAppear {
					viewModel.getPlaylists()
				}
		}
	}
}


