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
	@State private var searchText = ""
	@State private var response: Search2Response?
	@State private var scope: SearchScope = .song
	var body: some View {
		ZStack {
			List {
				switch scope {
				case .album:
					ForEach(response?.subsonicResponse.searchResult2.album ?? []) { album in
						Button {
							coordinator.albumTapped( albumId: album.id)
						} label: {
							let convertedAlbum = Album(searchResponse: album)
							HStack {
								AlbumCell(album: convertedAlbum)
								Spacer()
								Image(systemName: "chevron.right")
									.font(.body)
							}
						}
					}
				case .song:
					ForEach(response?.subsonicResponse.searchResult2.song ?? []) { cellSong in
						Button {
							self.player.play(songs: [Song(searchSong: cellSong)], index: 0)
						} label: {
							SongCell(song: Song(searchSong: cellSong))
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
					}
				}
			}
			.listStyle(.plain)
			.searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
			.autocorrectionDisabled(true)
			.onSubmit(of: .search) {
				Task {
					do {
						response = try await SubsonicClient.shared.search2(term: searchText.lowercased())
					} catch {
						response = nil
					}
				}
			}
			.searchScopes($scope) {
				ForEach(SearchScope.allCases, id: \.self) { scope in
					Text(scope.rawValue.capitalized)
				}
			}
		}
		.navigationTitle("Search")
	}
}

enum SearchScope: String, CaseIterable {
	case album, song
}
