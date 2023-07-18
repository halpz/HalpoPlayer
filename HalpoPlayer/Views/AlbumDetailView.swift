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
	@EnvironmentObject var database: Database
	init(albumId: String) {
		_viewModel = StateObject(wrappedValue: AlbumDetailViewModel(albumId: albumId))
	}
	var body: some View {
		if let songs = viewModel.albumResponse?.subsonicResponse.album.song {
			List {
				VStack(alignment: .leading) {
					if let album = viewModel.albumResponse?.subsonicResponse.album {
						Text("\(album.name)")
							.font(.title)
						Text("\(album.artist ?? "")")
							.font(.title2)
							.foregroundColor(.secondary)
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
						SongCell(showAlbumName: false, showTrackNumber: true, showAlbumArt: false, song: song)
					}
					.swipeActions {
						Button {
							viewModel.addSongToQueue(song: song)
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
					.listRowSeparator(.hidden)
					.onAppear {
						self.songAppeared(song: song)
					}
				}
			}
			.listStyle(.plain)
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
				coordinator.viewingAlbum = nil
			}
		} else {
			ProgressView()
				.onAppear {
					viewModel.getAlbum()
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
