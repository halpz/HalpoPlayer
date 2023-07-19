//
//  SearchView.swift
//  halpoplayer
//
//  Created by Paul Halpin on 12/07/2023.
//

import SwiftUI

struct SearchView: View {
	@EnvironmentObject var coordinator: Coordinator
	@EnvironmentObject var player: AudioManager
	@EnvironmentObject var database: Database
	var body: some View {
		ZStack {
			List {
				switch database.searchScope {
				case .album:
					ForEach(database.searchResults?.subsonicResponse.searchResult2.album ?? []) { album in
						Button {
							coordinator.albumTapped( albumId: album.id, scrollToSong: nil)
						} label: {
							let convertedAlbum = Album(searchResponse: album)
							HStack {
								AlbumCell(album: convertedAlbum)
							}
						}
						.listRowSeparator(.hidden)
					}
				case .song:
					ForEach(database.searchResults?.subsonicResponse.searchResult2.song ?? []) { cellSong in
						Button {
							self.player.play(songs: [Song(searchSong: cellSong)], index: 0)
						} label: {
							SongCell(showAlbumName: true, showTrackNumber: false, song: Song(searchSong: cellSong))
						}
						.swipeActions(allowsFullSwipe: false) {
							Button {
								self.player.addSongToQueue(song: Song(searchSong: cellSong))
							} label: {
								Image(systemName: "text.badge.plus").imageScale(.large)
							}
							.tint(.blue)
							if database.musicCache[Song(searchSong: cellSong).id] == nil {
								Button {
									self.database.cacheSong(song: Song(searchSong: cellSong)) {}
								} label: {
									Image(systemName: "arrow.down.app").imageScale(.large)
								}
								.tint(.green)
							} else {
								Button {
									self.database.deleteSong(song: Song(searchSong: cellSong))
								} label: {
									Image(systemName: "trash.fill").imageScale(.large)
								}
								.tint(.red)
							}
						}
						.listRowSeparator(.hidden)
					}
				}
			}
			.listStyle(.plain)
			.searchable(text: $database.searchText, placement: .navigationBarDrawer(displayMode: .always))
			.searchScopes($database.searchScope) {
				ForEach(SearchScope.allCases, id: \.self) { scope in
					Text(scope.rawValue.capitalized)
				}
			}
			.autocorrectionDisabled(true)
			.onSubmit(of: .search) {
				Task {
					do {
						database.searchResults = try await SubsonicClient.shared.search2(term: database.searchText.lowercased())
					} catch {
						database.searchResults = nil
					}
				}
			}
		}
		.navigationTitle("Search")
	}
}

enum SearchScope: String, CaseIterable {
	case song, album
}
