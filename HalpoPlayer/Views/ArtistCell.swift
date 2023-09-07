//
//  ArtistCell.swift
//  HalpoPlayer
//
//  Created by paul on 20/07/2023.
//

import SwiftUI
import UIKit

struct ArtistCell: View {
	var artist: GetArtistsResponse.Artist
	@State private var image: UIImage?
	let imageSize: CGFloat = 40
	var body: some View {
		HStack {
			if let image = image {
				Image(uiImage: image)
					.resizable()
					.scaledToFit()
					.frame(width: imageSize, height: imageSize)
					.clipShape(Circle())
			} else {
				Image(systemName: "person.circle")
					.font(.system(size: imageSize))
					.frame(width: imageSize, height: imageSize)
					.clipShape(Circle())
					.onAppear {
						Task {
							if let image = Database.shared.imageCache.image(albumId: artist.id) {
								self.image = image
							} else if let image = Database.shared.imageCache.image(albumId: artist.coverArt) {
								self.image = image
							} else {
								do {
									let downloadedImage = try await SubsonicClient.shared.downloadAvatar(artistId: artist.id, artistImageUrl: artist.artistImageUrl)
									self.image = downloadedImage
								} catch {
									let downloadedImage = try await SubsonicClient.shared.coverArt(albumId: artist.coverArt)
									self.image = downloadedImage
								}
							}
						}
					}
			}
			VStack(alignment: .leading) {
				Text(artist.name)
					.font(.body).bold()
				Text("\(artist.albumCount) album\(artist.albumCount == 1 ? "" : "s")")
					.font(.body)
					.foregroundColor(.secondary)
			}
			Spacer()
			Image(systemName: "chevron.right")
				.font(.body)
		}
	}
}
