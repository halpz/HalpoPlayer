//
//  ArtistView.swift
//  HalpoPlayer
//
//  Created by paul on 20/07/2023.
//

import SwiftUI

struct ArtistView: View {
	@EnvironmentObject var coordinator: Coordinator
	@StateObject var viewModel: ArtistViewModel
	init(artistId: String) {
		_viewModel = StateObject(wrappedValue: ArtistViewModel(artistId: artistId))
	}
	var body: some View {
		List {
			ForEach(viewModel.albums ?? []) { album in
				Button {
					coordinator.albumTapped(albumId: album.id, scrollToSong: nil)
				} label: {
					AlbumCell(album: album)
				}
				.listRowSeparator(.hidden)
			}
		}
		.listStyle(.plain)
		.navigationTitle(viewModel.artistName ?? "")
	}
}

class ArtistViewModel: ObservableObject {
	var artistId: String
	@Published var albums: [Album]?
	@Published var artistName: String?
	init(artistId: String) {
		self.artistId = artistId
		getArtistAlbums()
	}
	func getArtistAlbums() {
		Task {
			do {
				let response = try await SubsonicClient.shared.getArtist(id: artistId)
				let albums = response.subsonicResponse.artist.album.map { Album(artistResponse: $0)}
				DispatchQueue.main.async {
					self.artistName = response.subsonicResponse.artist.name
					self.albums = albums
				}
			} catch {
				print(error)
			}
		}
	}
}
