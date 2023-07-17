//
//  ContentView.swift
//  halpoplayer
//
//  Created by paul on 07/07/2023.
//

import SwiftUI

struct ContentView: View {
	@EnvironmentObject var coordinator: Coordinator
	@EnvironmentObject var player: AudioManager
	@EnvironmentObject var database: Database
	@EnvironmentObject var accountHolder: AccountHolder
	@State private var selectedAlbum: GetAlbumListResponse.Album?
	@State private var searchText: String = ""
	@State private var imageDictionary = [String: UIImage]()
	@State private var showLogin = false
	@State private var showSearch = false
	@State private var showDownloads = false
	var results: [GetAlbumListResponse.Album] {
		if searchText.isEmpty {
			return database.albums
		} else {
			return database.albums.filter {
				$0.title.localizedCaseInsensitiveContains(searchText) ||
				$0.artist.localizedCaseInsensitiveContains(searchText)
			}
		}
	}
	var body: some View {
		List(results) { album in
			Button {
				coordinator.albumTapped( albumId: album.id)
			} label: {
				HStack {
					if let image = imageDictionary[album.id] {
						Image(uiImage: image)
							.resizable()
							.scaledToFit()
							.cornerRadius(8)
							.frame(width: 60, height: 60)
					} else {
						ProgressView()
							.frame(width: 60, height: 60)
							.onAppear {
								Task {
									let image = try await SubsonicClient.shared.coverArt(albumId: album.id)
									self.imageDictionary[album.id] = image
								}
							}
					}
					VStack(alignment: .leading) {
						Text("\(album.title)")
							.font(.body).bold()
						Text("\(album.artist)")
							.font(.body)
							.foregroundColor(.secondary)
					}
					Spacer()
					Image(systemName: "chevron.right")
						.font(.body)
				}
			}
		}
		.simultaneousGesture(DragGesture().onChanged({ value in
			withAnimation {
				MediaControlBarMinimized.shared.isCompact = true
			}
		}))
		.refreshable {
			Task {
				do {
					let albums = try await SubsonicClient.shared.getAlbumList()
					self.database.albums = albums.subsonicResponse.albumList.album
				} catch {
					if try await SubsonicClient.shared.authenticate() {
						let albums = try await SubsonicClient.shared.getAlbumList()
						self.database.albums = albums.subsonicResponse.albumList.album
					}
				}
			}
		}
		.listStyle(.plain)
		.searchable(text: $searchText, prompt: "Search albums")
		.navigationTitle("Music")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .navigationBarLeading) {
				Button {
					coordinator.goToLogin()
				} label: {
					Image(systemName: "person.circle").imageScale(.large)
				}
			}
			ToolbarItem(placement: .navigationBarTrailing) {
				Button {
					Task {
						let response = try await SubsonicClient.shared.getRandomSongs()
						let songs = response.subsonicResponse.randomSongs.song.compactMap {
							return Song(randomSong: $0)
						}
						player.play(songs:songs, index: 0)
					}
				} label: {
					Image(systemName: "shuffle").imageScale(.large)
				}
			}
		}
	}
}
