//
//  PlaylistView.swift
//  HalpoPlayer
//
//  Created by paul on 18/07/2023.
//

import SwiftUI

struct PlaylistView: View {
	@StateObject var viewModel: PlaylistViewModel
	var name: String
	init(playlist: GetPlaylistsResponse.Playlist) {
		_viewModel = StateObject(wrappedValue: PlaylistViewModel(id: playlist.id))
		name = playlist.name
	}
	var body: some View {
		if viewModel.playlistResponse != nil {
			List {
				ForEach(viewModel.songs, id: \.self) { song in
					Button {
						viewModel.playSong(song: song)
					} label: {
						SongCell(showAlbumName: true, showTrackNumber: false, song: song)
					}
				}
			}
			.listStyle(.plain)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button {
						viewModel.playPlaylist()
					} label: {
						Image(systemName: "play.fill").imageScale(.large)
					}
				}
			}
		} else {
			ProgressView()
				.navigationTitle(name)
				.onAppear {
					viewModel.getPlaylist()
				}
		}
	}
}
