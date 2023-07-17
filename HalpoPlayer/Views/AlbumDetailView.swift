//
//  AlbumDetailView.swift
//  halpoplayer
//
//  Created by paul on 10/07/2023.
//

import SwiftUI

struct AlbumDetailView: View {
	@EnvironmentObject var coordinator: Coordinator
	var albumId: String
	@EnvironmentObject var player: AudioManager
	@EnvironmentObject var database: Database
	@State var albumResponse: GetAlbumResponse?
	@State private var image: UIImage?
	@State private var downloadingSongs = [Song]()
	var playButtonName: String {
		if let currentSong = player.currentSong,
		   let songs = albumResponse?.subsonicResponse.album.song,
		   player.isPlaying && songs.contains(currentSong) {
			return "pause.circle.fill"
		} else {
			return "play.circle.fill"
		}
	}
	var body: some View {
		if let songs = albumResponse?.subsonicResponse.album.song {
			List {
				VStack(alignment: .leading) {
					if let album = albumResponse?.subsonicResponse.album {
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
				if let image = image {
					HStack {
						Spacer()
						ZStack {
							Image(uiImage: image)
								.resizable()
								.scaledToFit()
								.cornerRadius(8)
								.padding(8)
								.frame(maxWidth: 400, maxHeight: 400)
							Button {
								playButtonPressed()
							} label: {
								Image(systemName: playButtonName)
									.imageScale(.large)
									.foregroundStyle(.primary, Color.accentColor)
									.symbolRenderingMode(.palette)
									.font(.system(size:72))
									.opacity(0.8)
							}
						}
						Spacer()
					}
				}
				HStack {
					Spacer()
					Button {
						Task {
							let shuffled = songs.shuffled()
							player.play(songs:shuffled, index: 0)
						}
					} label: {
						Image(systemName: "shuffle").imageScale(.large)
							.foregroundColor(Color.accentColor)
					}
					.buttonStyle(.plain)
					.padding(8)
					Spacer()
					Button {
						Task {
							songs.forEach {
								self.database.deleteSong(song: $0)
								self.downloadingSongs.append($0)
							}
							for song in songs {
								self.database.cacheSong(song: song) {
									if let index = self.downloadingSongs.firstIndex(of: song) {
										self.downloadingSongs.remove(at: index)
									}
								}
							}
						}
					} label: {
						Image(systemName: "arrow.down.square").imageScale(.large)
							.foregroundColor(Color.accentColor)
					}
					.buttonStyle(.plain)
					.padding(8)
					Spacer()
				}
				
				ForEach(songs) { song in
					Button {
						if let index = songs.firstIndex(of: song) {
							self.player.play(songs: songs, index: index)
						}
					} label: {
						HStack {
							if let trackNumber = song.track {
								Text("\(trackNumber)")
									.font(.body)
									.foregroundColor(.secondary)
									.padding(8)
							}
							VStack(alignment: .leading) {
								Text("\(song.title)")
									.font(.body).bold()
									.foregroundColor(player.currentSong == song ? .accentColor : .primary)
								Text("\(song.artist)")
									.font(.body)
									.foregroundColor(.secondary)
							}
							
							Spacer()
							if downloadingSongs.contains(song) {
								ProgressView()
							} else if database.musicCache[song.id] != nil {
								Image(systemName: "arrow.down.circle.fill").imageScale(.large)
									.foregroundColor(.green)
							}
						}
						.padding(8)
					}
					.swipeActions {
						Button {
							self.player.addSongToQueue(song: song)
						} label: {
							Image(systemName: "text.badge.plus").imageScale(.large)
						}
						.tint(.blue)
						if song.suffix != "opus" {
							if database.musicCache[song.id] == nil {
								Button {
									self.downloadingSongs.append(song)
									self.database.cacheSong(song: song) {
										if let index = self.downloadingSongs.firstIndex(of: song) {
											self.downloadingSongs.remove(at: index)
										}
									}
								} label: {
									Image(systemName: "arrow.down.app").imageScale(.large)
								}
								.tint(.green)
							} else {
								Button {
									self.database.deleteSong(song: song)
								} label: {
									Image(systemName: "trash.fill").imageScale(.large)
								}
								.tint(.red)
							}
						}
					}
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
						deleteAlbumFromCache()
					}
					
				} label: {
					Image(systemName: "ellipsis")
				}
				
			}
			.onAppear {
				coordinator.viewingAlbum = self.albumId
			}
			.onDisappear {
				coordinator.viewingAlbum = nil
			}
		} else {
			ProgressView()
				.onAppear {
					Task {
						do {
							albumResponse = try await SubsonicClient.shared.getAlbum(id: albumId)
							image = try await SubsonicClient.shared.coverArt(albumId: albumId)
						} catch {
							print(error)
						}
					}
				}
		}
	}
	func playButtonPressed() {
		if let currentSong = player.currentSong,
		   let songs = albumResponse?.subsonicResponse.album.song,
		   player.isPlaying && songs.contains(currentSong) {
			self.player.queue.pause()
		} else {
			if let songs = albumResponse?.subsonicResponse.album.song {
				if self.player.songs == songs {
					self.player.queue.play()
				} else {
					self.player.play(songs: songs, index: 0)
				}
			}
		}
	}
	func deleteAlbumFromCache() {
		for song in albumResponse?.subsonicResponse.album.song ?? [] where database.musicCache[song.id] != nil {
			database.deleteSong(song: song)
		}
	}
	func songAppeared(song: Song) {
		guard MediaControlBarMinimized.shared.isCompact == false else { return }
		withAnimation {
			MediaControlBarMinimized.shared.isCompact = true
		}
	}
}
