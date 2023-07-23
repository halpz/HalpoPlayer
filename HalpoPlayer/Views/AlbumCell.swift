//
//  AlbumCell.swift
//  halpoplayer
//
//  Created by paul on 13/07/2023.
//

import SwiftUI

struct AlbumCell: View {
	@EnvironmentObject var database: Database
	let album: Album
	var showArtistName = true
	@State var image: UIImage?
	let imageSize: CGFloat = 60
	var body: some View {
		HStack {
			HStack {
				if let image = image {
					Image(uiImage: image)
						.resizable()
						.scaledToFit()
						.cornerRadius(8)
						.frame(width: imageSize, height: imageSize)
				} else {
					ProgressView()
						.frame(width: imageSize, height: imageSize)
						.onAppear {
							Task {
								image = try await SubsonicClient.shared.coverArt(albumId: album.id)
							}
						}
				}
				VStack(alignment: .leading) {
					Text("\(album.name)")
						.font(.body).bold()
					if showArtistName {
						Text("\(album.artist ?? "")")
							.font(.body)
							.foregroundColor(.secondary)
					}
				}
				Spacer()
				Image(systemName: "chevron.right")
					.font(.body)
			}
		}
	}
}

struct AlbumGridCell: View {
	@EnvironmentObject var database: Database
	let album: Album
	var showArtistName = true
	@State var image: UIImage?
	let imageSize: CGFloat = 60
	var body: some View {
		VStack(alignment: .leading) {
			if let image = image {
				Image(uiImage: image)
					.resizable()
					.scaledToFit()
					.cornerRadius(8)
			} else {
				ProgressView()
					.onAppear {
						Task {
							image = try await SubsonicClient.shared.coverArt(albumId: album.id)
						}
					}
			}
			VStack(alignment: .leading) {
				Text("\(album.name)")
					.foregroundColor(.primary)
					.multilineTextAlignment(.leading)
					.font(.body).bold()
				if showArtistName {
					Text("\(album.artist ?? "")")
						.font(.body)
						.multilineTextAlignment(.leading)
						.foregroundColor(.secondary)
						.lineLimit(2)
				}
			}
		}
		.padding(8)
		.background(Color("TextBackground"))
		.cornerRadius(8)
	}
}
