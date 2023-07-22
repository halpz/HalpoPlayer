//
//  PlaylistsView.swift
//  HalpoPlayer
//
//  Created by paul on 18/07/2023.
//

import SwiftUI

struct PlaylistsView: View {
	@StateObject var viewModel: PlaylistsViewModel
	@EnvironmentObject var coordinator: Coordinator
	@EnvironmentObject var database: Database
	init(_ song: Song? = nil, refresh: Bool = false) {
		_viewModel = StateObject(wrappedValue: PlaylistsViewModel(song, refresh: refresh))
	}
	var body: some View {
		if let playlists = database.playlists {
			List {
				ForEach(playlists.subsonicResponse.playlists.playlist, id: \.self) { playlist in
					Button {
						if viewModel.song != nil {
							viewModel.addSongToPlaylist(playlistId: playlist.id, coordinator: coordinator)
						} else {
							viewModel.goToPlaylist(playlist: playlist, coordinator: coordinator)
						}
					} label: {
						PlaylistCell(showChevron: viewModel.song == nil, playlist: playlist)
					}
					.listRowSeparator(.hidden)
					.onAppear {
						withAnimation {
							viewModel.cellDidAppear(playlist: playlist)
						}
					}
				}
			}
			.refreshable {
				viewModel.getPlaylists()
			}
			.listStyle(.plain)
			.navigationTitle(viewModel.song != nil ? "Choose playlist" : "Playlists")
		} else {
			ProgressView()
		}
	}
}


