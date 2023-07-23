//
//  ArtistViewModel.swift
//  HalpoPlayer
//
//  Created by Paul Halpin on 23/07/2023.
//

import UIKit

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
		loadData()
	}
	func loadData() {
		Task {
			do {
				let response = try await SubsonicClient.shared.getArtist(id: artistId)
				self.response = response
				let albums = response.subsonicResponse.artist.album.map { Album(artistResponse: $0)}
				DispatchQueue.main.async {
					self.albums = albums
				}
			} catch {
				print(error)
			}
			do {
				try await getArtistImage()
			} catch {
				print("Could not get artist image: \(error)")
			}
			do {
				try await getArtistBio()
			} catch {
				print("could not get artist info: \(error)")
			}
		}
	}
	func getArtistImage() async throws {
		guard let artist = response?.subsonicResponse.artist else {
			throw HalpoError.noURL
		}
		var artistImage: UIImage?
		
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
		}
	}
	func getArtistBio() async throws {
		let info = try await SubsonicClient.shared.getArtistInfo(id: artistId)
		let bio = info.subsonicResponse.artistInfo.biography
		let string = bio.replacingOccurrences(of: "<a target='_blank' href=\"(.+)\" rel=\"nofollow\">(.+)</a>", with: "[$2]($1)", options: .regularExpression, range: nil)
		DispatchQueue.main.async {
			self.info = info
			self.bio = string
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
