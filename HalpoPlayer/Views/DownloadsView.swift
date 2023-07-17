//
//  DownloadsView.swift
//  halpoplayer
//
//  Created by Paul Halpin on 12/07/2023.
//

import SwiftUI

struct DownloadsView: View {
	@EnvironmentObject var coordinator: Coordinator
	@EnvironmentObject var database: Database
	@State private var showAlert = false
	@State private var type: DownloadsType = .songs
	@State private var searchText = ""
	var downloads: [CachedSong] {
		var sortedSongs = database.musicCache.map {$1}.sorted { ($0.song.track ?? 0) < ($1.song.track ?? 0) }
		sortedSongs = sortedSongs.sorted { $0.album.name < $1.album.name }
		if !searchText.isEmpty {
			sortedSongs = sortedSongs.filter {
				$0.song.title.localizedCaseInsensitiveContains(searchText) ||
				$0.song.artist.localizedCaseInsensitiveContains(searchText)
			}
		}
		return sortedSongs
	}
	var albums: [Album] {
		var albumsDict = [String: Album]()
		for (_, value) in database.musicCache {
			albumsDict[value.album.id] = value.album
		}
		var sortedAlbums = albumsDict.map {$1}.sorted { $0.name < $1.name }
		if !searchText.isEmpty {
			sortedAlbums = sortedAlbums.filter {
				$0.name.localizedCaseInsensitiveContains(searchText)
			}
		}
		return sortedAlbums
	}
	var body: some View {
		if downloads.isEmpty {
			Text("No downloads")
				.foregroundColor(.secondary)
				.navigationTitle("Downloads")
		} else {
			VStack {
				List {
					Section {
						switch type {
						case .songs:
							ForEach(downloads) { file in
								Button {
									
									if let index = downloads.firstIndex(of: file) {
										AudioManager.shared.play(songs: downloads.map {$0.song}, index: index)
									} else {
										print("not found")
									}
								} label: {
									SongCell(song: file.song)
								}
								.swipeActions {
									Button(role: .destructive) {
										self.database.deleteSong(song: file.song)
									} label: {
										Image(systemName: "trash.fill").imageScale(.large)
									}
									Button {
										AudioManager.shared.addSongToQueue(song: file.song)
									} label: {
										Image(systemName: "text.badge.plus").imageScale(.large)
									}
									.tint(.blue)
								}
								.onAppear {
									self.songAppeared(song: file.song)
								}
							}
						case .albums:
							ForEach(albums) { album in
								Button {
									if SubsonicClient.shared.currentAddress == nil {
										coordinator.albumTappedOffline(album: album)
									} else {
										coordinator.albumTapped( albumId: album.id)
									}
								} label: {
									HStack {
										AlbumCell(album: album)
										Spacer()
										Image(systemName: "chevron.right")
											.font(.body)
									}
								}
							}
						}
					} header: {
						Picker("type", selection: $type) {
							ForEach(DownloadsType.allCases, id: \.self) {
								Text($0.rawValue.capitalized)
							}
						}
						.pickerStyle(.segmented)
					}
				}
				.listStyle(.plain)
			}
			.navigationTitle("Downloads")
			.toolbar {
				if !downloads.isEmpty {
					ToolbarItem(placement: .navigationBarTrailing) {
						Button {
							Task {
								let shuffled = downloads.map {
									$0.song
								}.shuffled()
								AudioManager.shared.play(songs: shuffled, index: 0)
							}
						} label: {
							Image(systemName: "shuffle").imageScale(.large)
								.foregroundColor(Color.accentColor)
						}
					}
					ToolbarItem(placement: .navigationBarTrailing) {
						Button(role: .destructive) {
							showAlert = true
						} label: {
							Image(systemName: "trash.fill").imageScale(.large)
								.foregroundColor(.red)
						}
						.alert("Delete all downloads?", isPresented: $showAlert) {
							Button("Delete", role: .destructive) {
								for download in downloads {
									database.deleteSong(song: download.song)
								}
							}
							Button("Cancel", role: .cancel) {}
						}
					}
				}
			}
		}
	}
	func songAppeared(song: Song) {
		guard MediaControlBarMinimized.shared.isCompact == false else { return }
		withAnimation {
			MediaControlBarMinimized.shared.isCompact = true
		}
	}
}

enum DownloadsType: String, CaseIterable {
	case songs, albums
}

struct OfflineAlbumView: View {
	@EnvironmentObject var database: Database
	let album: Album
	var songs: [CachedSong] {
		var tempSongs = [CachedSong]()
		for (_, value) in database.musicCache where value.album.id == album.id {
			tempSongs.append(value)
		}
		tempSongs = tempSongs.sorted {
			($0.song.track ?? 0) < ($1.song.track ?? 0)
		}
		return tempSongs
	}
	var body: some View {
		List {
			ForEach(songs) { file in
				Button {
					if let index = songs.firstIndex(of: file) {
						AudioManager.shared.play(songs: songs.map {$0.song}, index: index)
					} else {
						print("not found")
					}
				} label: {
					SongCell(song: file.song)
				}
				.swipeActions {
					Button(role: .destructive) {
						self.database.deleteSong(song: file.song)
					} label: {
						Image(systemName: "trash.fill").imageScale(.large)
					}
					Button {
						AudioManager.shared.addSongToQueue(song: file.song)
					} label: {
						Image(systemName: "text.badge.plus").imageScale(.large)
					}
					.tint(.blue)
				}
			}
		}
		.listStyle(.plain)
		.navigationTitle(album.name)
	}
}
