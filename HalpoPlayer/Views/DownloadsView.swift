//
//  DownloadsView.swift
//  halpoplayer
//
//  Created by Paul Halpin on 12/07/2023.
//

import SwiftUI

struct DownloadsView: View {
	@StateObject var viewModel = DownloadsViewModel()
	@EnvironmentObject var coordinator: Coordinator
	@EnvironmentObject var database: Database
	var body: some View {
		if viewModel.downloads.isEmpty {
			Text("No downloads")
				.foregroundColor(.secondary)
				.navigationTitle("Downloads")
		} else {
			VStack {
				List {
					Section {
						switch viewModel.downloadsType {
						case .songs:
							ForEach(viewModel.downloads) { file in
								Button {
									viewModel.playSong(file: file)
								} label: {
									SongCell(showAlbumName: true, showTrackNumber: false, song: file.song)
								}
								.swipeActions {
									Button(role: .destructive) {
										viewModel.deleteSong(file: file)
									} label: {
										Image(systemName: "trash.fill").imageScale(.large)
									}
									Button {
										viewModel.addSongToQueue(file: file)
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
							ForEach(viewModel.albums) { album in
								Button {
									viewModel.albumTapped(album: album, coordinator: coordinator)
								} label: {
									HStack {
										AlbumCell(album: album)
									}
								}
							}
						}
					} header: {
						Picker("type", selection: $viewModel.downloadsType) {
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
				if !viewModel.downloads.isEmpty {
					ToolbarItem(placement: .navigationBarTrailing) {
						Button {
							viewModel.shuffle()
						} label: {
							Image(systemName: "shuffle").imageScale(.large)
								.foregroundColor(Color.accentColor)
						}
					}
					ToolbarItem(placement: .navigationBarTrailing) {
						Button(role: .destructive) {
							viewModel.showAlert = true
						} label: {
							Image(systemName: "trash.fill").imageScale(.large)
								.foregroundColor(.red)
						}
						.alert("Delete all downloads?", isPresented: $viewModel.showAlert) {
							Button("Delete", role: .destructive) {
								viewModel.deleteAll()
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
