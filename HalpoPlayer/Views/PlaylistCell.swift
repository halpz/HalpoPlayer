//
//  PlaylistCell.swift
//  HalpoPlayer
//
//  Created by paul on 18/07/2023.
//

import SwiftUI
import UIKit

struct PlaylistCell: View {
	var playlist: GetPlaylistsResponse.Playlist
	@State private var image: UIImage?
	var body: some View {
		HStack {
			if let image = image {
				Image(uiImage: image)
					.resizable()
					.scaledToFit()
					.frame(width: 50, height: 50)
			} else {
				ProgressView()
					.onAppear {
						Task {
							image = try await SubsonicClient.shared.coverArt(albumId: playlist.coverArt)
						}
					}
			}
			VStack(alignment: .leading) {
				Text(playlist.name)
				Text("\(playlist.songCount) song\(playlist.songCount == 1 ? "" : "s")")
			}
			Spacer()
			Image(systemName: "chevron.right")
				.font(.body)
		}
		.padding(8)
	}
}
