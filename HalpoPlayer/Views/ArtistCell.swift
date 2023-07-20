//
//  ArtistCell.swift
//  HalpoPlayer
//
//  Created by paul on 20/07/2023.
//

import SwiftUI
import UIKit

struct ArtistCell: View {
	var artist: GetIndexesResponse.Artist
	@State private var image: UIImage?
	var body: some View {
		HStack {
			if let image = image {
				Image(uiImage: image)
					.resizable()
					.scaledToFit()
					.frame(width: 60, height: 60)
					.clipShape(Circle())
			} else {
				Image(systemName: "person.circle")
					.font(.system(size: 60))
					.frame(width: 60, height: 60)
					.clipShape(Circle())
					.onAppear {
						Task {
							let downloadedImage = try await SubsonicClient.shared.downloadAvatar(artist: artist)
							self.image = downloadedImage
						}
					}
			}
			Text(artist.name)
				.font(.body)
			Spacer()
			Image(systemName: "chevron.right")
				.font(.body)
		}
	}
}
