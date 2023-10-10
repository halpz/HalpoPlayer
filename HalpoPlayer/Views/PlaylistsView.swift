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
	@ObservedObject var database = Database.shared
	init(_ songs: [Song] = [], refresh: Bool = false) {
		_viewModel = StateObject(wrappedValue: PlaylistsViewModel(songs, refresh: refresh))
	}
	var body: some View {
		let toolbar = ToolbarItem(placement: .navigationBarTrailing) {
			Button {
				viewModel.showPrompt = true
			} label: {
				Image(systemName: "plus").imageScale(.large)
					.foregroundColor(Color.accentColor)
			}
			.alert("Enter a name for your playlist", isPresented: $viewModel.showPrompt) {
				TextField("Name", text: $viewModel.playlistName)
				Button("Create") {
					viewModel.createPlaylist(name: viewModel.playlistName)
				}
				Button("Cancel", role: .cancel) {}
			}
		}
		if let playlists = database.playlists,
		   !(playlists.subsonicResponse.playlists.playlist?.isEmpty ?? true) {
			List {
				ForEach(playlists.subsonicResponse.playlists.playlist ?? [], id: \.self) { playlist in
					Button {
						if !viewModel.songs.isEmpty {
							viewModel.addSongsToPlaylist(playlistId: playlist.id, coordinator: coordinator)
						} else {
							viewModel.goToPlaylist(playlist: playlist, coordinator: coordinator)
						}
					} label: {
						PlaylistCell(showChevron: viewModel.songs.isEmpty, playlist: playlist)
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
				do {
					try await viewModel.getPlaylists()
				} catch {
					print(error)
				}
			}
			.listStyle(.plain)
			.navigationTitle(!viewModel.songs.isEmpty ? "Choose playlist" : "Playlists")
			.toolbar {
				toolbar
			}
		} else {
			if viewModel.loading {
				ProgressView()
			} else {
				Text("No playlists")
					.navigationTitle(!viewModel.songs.isEmpty ? "Choose playlist" : "Playlists")
					.toolbar {
						toolbar
					}
			}
		}
	}
}


