//
//  PlaylistView.swift
//  HalpoPlayer
//
//  Created by paul on 18/07/2023.
//

import SwiftUI

struct PlaylistView: View {
	@StateObject var viewModel: PlaylistViewModel
	@EnvironmentObject var player: AudioManager
	@State private var editMode = EditMode.active
	var name: String
	init(playlist: GetPlaylistsResponse.Playlist) {
		_viewModel = StateObject(wrappedValue: PlaylistViewModel(id: playlist.id))
		name = playlist.name
	}
	var body: some View {
		if viewModel.playlistResponse != nil {
			List {
				if let image = viewModel.image {
					HStack {
						Spacer()
						ZStack {
							Image(uiImage: image)
								.resizable()
								.scaledToFit()
								.cornerRadius(8)
								.frame(maxWidth: 500, maxHeight: 500)
							Button {
								viewModel.playPlaylist()
							} label: {
								Image(systemName: viewModel.playButtonName)
									.imageScale(.large)
									.foregroundStyle(.primary, Color.accentColor)
									.symbolRenderingMode(.palette)
									.font(.system(size:72))
									.opacity(0.8)
							}
						}
						Spacer()
					}
					.listRowSeparator(.hidden)
				}
				ForEach(viewModel.songs, id: \.self) { song in
					Button {
						viewModel.playSong(song: song)
					} label: {
						SongCell(showAlbumName: true, showTrackNumber: false, song: song)
					}
					.listRowSeparator(.hidden)
					.onAppear {
						withAnimation {
							viewModel.cellDidAppear(song: song)
						}
					}
				}
			}
			.listStyle(.plain)
			.navigationTitle(name)
		} else {
			ProgressView()
				.navigationTitle(name)
		}
	}
}
