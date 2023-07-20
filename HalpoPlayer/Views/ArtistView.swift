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
			if let info = viewModel.info {
				Text(info.subsonicResponse.artistInfo.biography)
			}
			ForEach(viewModel.albums ?? []) { album in
				Button {
					coordinator.albumTapped(albumId: album.id, scrollToSong: nil)
				} label: {
					AlbumCell(album: album, showArtistName: false)
				}
				.listRowSeparator(.hidden)
			}
		}
		.refreshable {
			viewModel.getArtistAlbums()
		}
		.listStyle(.plain)
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button {
					viewModel.shuffle()
				} label: {
					Image(systemName: "shuffle").imageScale(.large)
				}
			}
		}
	}
}

class ArtistViewModel: ObservableObject {
	var player = AudioManager.shared
	var artistId: String
	var response: GetArtistResponse?
	var info: GetArtistInfoResponse?
	@Published var bio: String?
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
					self.response = response
					self.image = finalImage
					self.albums = albums
				}
			} catch {
				print(error)
			}
//			do {
//				let info = try await SubsonicClient.shared.getArtistInfo(id: artistId)
//
////				let pattern = "<a target='_blank' href=\"(.+)\" rel=\"nofollow\">(.+)</a>"
////
////				let string = info.subsonicResponse.artistInfo.biography.replacingOccurrences(of: pattern,
////												  with: "[$2]($1)",
////												  options: .regularExpression,
////												  range: nil)
//
//
//				let string = info.subsonicResponse.artistInfo.biography
//
//				DispatchQueue.main.async {
//					self.info = info
//					self.bio = string
//				}
//			} catch {
//				print("could not get artist info: \(error)")
//			}
		}
	}
	func shuffle() {
		Task {
			var songs = [Song]()
			for album in self.response?.subsonicResponse.artist.album ?? [] {
				let respones = try await SubsonicClient.shared.getAlbum(id: album.id)
				songs.append(contentsOf: respones.subsonicResponse.album.song)
			}
			let finalSongs = songs
			DispatchQueue.main.async {
				self.player.play(songs:finalSongs, index: 0)
			}
		}
	}
}
