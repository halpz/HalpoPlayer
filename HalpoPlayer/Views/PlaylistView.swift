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

class PlaylistViewModel: ObservableObject {
	var playlistId: String
	var player = AudioManager.shared
	@Published var playlistResponse: GetPlaylistResponse?
	init(id: String) {
		playlistId = id
	}
	var songs: [Song] {
		return playlistResponse?.subsonicResponse.playlist.entry.map {
			Song(playlistEntry: $0)
		} ?? []
	}
	func getPlaylist() {
		Task {
			let response = try await SubsonicClient.shared.getPlaylist(id: playlistId)
			DispatchQueue.main.async {
				self.playlistResponse = response
			}
		}
	}
	func playSong(song: Song) {
		if let index = songs.firstIndex(of: song) {
			self.player.play(songs: songs, index: index)
		}
	}
	func playPlaylist() {
		guard !songs.isEmpty else {return}
		self.player.play(songs: songs, index: 0)
	}
}
