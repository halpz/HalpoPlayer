//
//  ArtistView.swift
//  HalpoPlayer
//
//  Created by paul on 20/07/2023.
//

import SwiftUI
import UIKit

struct ArtistView: View {
	@EnvironmentObject var coordinator: Coordinator
	@StateObject var viewModel: ArtistViewModel
	init(artistId: String, artistName: String) {
		_viewModel = StateObject(wrappedValue: ArtistViewModel(artistId: artistId, artistName: artistName))
	}
	var body: some View {
		List {
			Text(viewModel.artistName).font(.largeTitle)
			HStack {
				Spacer()
				if let image = viewModel.image {
					Image(uiImage: image)
						.resizable()
						.scaledToFit()
						.frame(width: 200, height: 200)
						.clipShape(Circle())
				}
				Spacer()
			}
			.padding()
			.listRowSeparator(.hidden)
			ForEach(viewModel.albums ?? []) { album in
				Button {
					coordinator.albumTapped(albumId: album.id, scrollToSong: nil)
				} label: {
					AlbumCell(album: album, showArtistName: false)
				}
				.listRowSeparator(.hidden)
			}
		}
		.listStyle(.plain)
	}
}

class ArtistViewModel: ObservableObject {
	var artistId: String
	@Published var albums: [Album]?
	var artistName: String
	@Published var image: UIImage?
	init(artistId: String, artistName: String) {
		self.artistId = artistId
		self.artistName = artistName
		getArtistAlbums()
	}
	func getArtistAlbums() {
		Task {
			do {
				let response = try await SubsonicClient.shared.getArtist(id: artistId)
				let albums = response.subsonicResponse.artist.album.map { Album(artistResponse: $0)}
				
				var artistImage: UIImage?
				let artist = response.subsonicResponse.artist
				
				if let image = Database.shared.imageCache.image(albumId: artist.id) {
					artistImage = image
				} else if let image = Database.shared.imageCache.image(albumId: artist.coverArt) {
					artistImage = image
				} else {
					do {
						let downloadedImage = try await SubsonicClient.shared.downloadAvatar(artistId: artistId, artistImageUrl: artist.artistImageUrl)
						artistImage = downloadedImage
					} catch {
						let downloadedImage = try await SubsonicClient.shared.coverArt(albumId: artist.coverArt)
						artistImage = downloadedImage
					}
				}
				let finalImage = artistImage
				DispatchQueue.main.async {
					self.image = finalImage
					self.albums = albums
				}
			} catch {
				print(error)
			}
		}
	}
}
