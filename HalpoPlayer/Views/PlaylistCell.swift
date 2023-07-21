//
//  PlaylistCell.swift
//  HalpoPlayer
//
//  Created by paul on 18/07/2023.
//

import SwiftUI
import UIKit

struct PlaylistCell: View {
	var showChevron = true
	var playlist: GetPlaylistsResponse.Playlist
	@State private var image: UIImage?
	var body: some View {
		HStack {
			if let image = image {
				Image(uiImage: image)
					.resizable()
					.scaledToFit()
					.frame(width: 60, height: 60)
			} else {
				ProgressView()
					.frame(width: 60, height: 60)
					.onAppear {
						Task {
							image = try await SubsonicClient.shared.coverArt(albumId: playlist.coverArt)
						}
					}
			}
			VStack(alignment: .leading) {
				Text(playlist.name)
				Text("\(playlist.songCount) song\(playlist.songCount == 1 ? "" : "s")")
					.foregroundColor(.secondary)
			}
			Spacer()
			if showChevron {
				Image(systemName: "chevron.right")
					.font(.body)
			}
		}
		.padding(8)
		
	}
}
