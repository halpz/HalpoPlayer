//
//  AlbumDetailView.swift
//  halpoplayer
//
//  Created by paul on 10/07/2023.
//

import SwiftUI

struct AlbumDetailView: View {
	@StateObject private var viewModel: AlbumDetailViewModel
	@EnvironmentObject var coordinator: Coordinator
	@ObservedObject var database = Database.shared
	@ObservedObject var player = AudioManager.shared
	init(albumId: String, scrollToSong: String? = nil) {
		_viewModel = StateObject(wrappedValue: AlbumDetailViewModel(albumId: albumId, scrollToSong: scrollToSong))
	}
	var body: some View {
		if let songs = viewModel.albumResponse?.subsonicResponse.album.song {
			ScrollViewReader { proxy in
				List {
					VStack(alignment: .leading) {
						if let album = viewModel.albumResponse?.subsonicResponse.album {
							Text("\(album.name)")
								.font(.title)
							Button {
								viewModel.goToArtist(coordinator)
							} label: {
								Text("\(album.artist ?? "")")
									.font(.title2)
									.foregroundColor(.secondary)
							}
							if let year = album.year {
								Text(String(year))
									.font(.title3)
									.foregroundColor(.secondary)
							}
						}
					}
					.listRowSeparator(.hidden)
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
									viewModel.playButtonPressed()
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
					HStack {
						Spacer()
						Button {
							viewModel.shuffleSongs(songs: songs)
						} label: {
							Image(systemName: "shuffle").imageScale(.large)
								.foregroundColor(Color.accentColor)
						}
						.buttonStyle(.plain)
						.padding(8)
						Spacer()
						Button {
							viewModel.downloadAll(songs: songs)
						} label: {
							Image(systemName: "arrow.down.square").imageScale(.large)
								.foregroundColor(Color.accentColor)
						}
						.buttonStyle(.plain)
						.padding(8)
						Spacer()
					}
					.listRowSeparator(.hidden)
					ForEach(songs) { song in
						Button {
							viewModel.playSong(song: song, songs: songs)
						} label: {
							let downloading = viewModel.downloading[song.id] ?? false
							SongCell(downloading: downloading, showAlbumName: false, showTrackNumber: true, showAlbumArt: false, song: song)
						}
						.swipeActions {
							Button {
//								viewModel.addSongToQueue(song: song)
								viewModel.addSongToPlaylist(song: song, coordinator: coordinator)
							} label: {
								Image(systemName: "text.badge.plus").imageScale(.large)
							}
							.tint(.blue)
							if song.suffix != "opus" {
								if database.musicCache[song.id] == nil {
									Button {
										viewModel.downloadSong(song: song)
									} label: {
										Image(systemName: "arrow.down.app").imageScale(.large)
									}
									.tint(.green)
								} else {
									Button {
										viewModel.deleteSong(song: song)
									} label: {
										Image(systemName: "trash.fill").imageScale(.large)
									}
									.tint(.red)
								}
							}
						}
						.id(song.id)
						.listRowSeparator(.hidden)
						.onAppear {
							self.songAppeared(song: song)
						}
					}
				}
				.listStyle(.plain)
				.onChange(of: viewModel.scrollToSong) { newValue in
					if let songs = viewModel.albumResponse?.subsonicResponse.album.song,
					   let currentSong = player.currentSong {
						if songs.contains(currentSong) {
							withAnimation {
								proxy.scrollTo(newValue, anchor: .center)
							}
						}
					}
				}
			}
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				Menu {
					Button("Delete from cache") {
						viewModel.deleteAlbumFromCache()
					}
					
				} label: {
					Image(systemName: "ellipsis")
				}
				
			}
			.onAppear {
				coordinator.viewingAlbum = viewModel.albumId
			}
			.onDisappear {
				if coordinator.viewingAlbum == viewModel.albumId {
					coordinator.viewingAlbum = nil
				}
			}
		} else {
			ProgressView()
		}
	}
	func songAppeared(song: Song) {
		guard MediaControlBarMinimized.shared.isCompact == false else { return }
		withAnimation {
			MediaControlBarMinimized.shared.isCompact = true
		}
	}
}
