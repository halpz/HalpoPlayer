//
//  AlbumCell.swift
//  halpoplayer
//
//  Created by paul on 13/07/2023.
//

import SwiftUI

struct AlbumCell: View {
	let album: Album
	@State var image: UIImage?
	var body: some View {
		HStack {
			HStack {
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
								image = try await SubsonicClient.shared.coverArt(albumId: album.id)
							}
						}
				}
				VStack(alignment: .leading) {
					Text("\(album.name)")
						.font(.body).bold()
					Text("\(album.artist ?? "")")
						.font(.body)
						.foregroundColor(.secondary)
				}
			}
		}
		.padding(8)
	}
}
