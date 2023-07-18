//
//  SongCell.swift
//  halpoplayer
//
//  Created by paul on 13/07/2023.
//

import SwiftUI

struct SongCell: View {
	var downloading: Bool = false
	var showAlbumName: Bool = true
	var showTrackNumber: Bool = true
	var showAlbumArt: Bool = true
	@EnvironmentObject var player: AudioManager
	@EnvironmentObject var database: Database
	let song: Song
	@State var image: UIImage?
	var body: some View {
		HStack {
			HStack {
				if showTrackNumber, let trackNumber = song.track {
					Text("\(trackNumber)")
						.font(.body)
						.foregroundColor(.secondary)
						.frame(width: 20)
						.padding(8)
						
				}
				if showAlbumArt {
					if let image = image {
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
									image = try await SubsonicClient.shared.coverArt(albumId: song.albumId)
								}
							}
					}
				}
				VStack(alignment: .leading) {
					Text("\(song.title)")
						.font(.body).bold()
						.foregroundColor(player.currentSong == song ? .accentColor : .primary)
					if showAlbumName {
						Text("\(song.album)")
							.font(.body)
							.foregroundColor(.secondary)
					}
					Text("\(song.artist)")
						.font(.body)
						.foregroundColor(.secondary)
				}
				
				Spacer()
				
				if downloading {
					ProgressView()
				} else if database.musicCache[song.id] != nil {
					Image(systemName: "arrow.down.circle.fill").imageScale(.large)
						.foregroundColor(.green)
				}
			}
		}
	}
}
