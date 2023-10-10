//
//  Coordinator.swift
//  halpoplayer
//
//  Created by paul on 14/07/2023.
//

import SwiftUI

class Coordinator: ObservableObject {
	var viewingAlbum: String?
	@Published var path = NavigationPath()
	func albumTapped(albumId: String, scrollToSong: String?) {
		path.append(Destination.albumView(albumId: albumId, scrollToSong: scrollToSong))
	}
	func downloadsTapped() {
		path.append(Destination.downloads)
	}
	func goToLogin() {
		path.append(Destination.login)
	}
	func goToSearch() {
		path.append(Destination.search)
	}
	func albumTappedOffline(album: Album) {
		path.append(Destination.albumViewOffline(album: album))
	}
	func goToPlaylist(playlist: GetPlaylistsResponse.Playlist) {
		path.append(Destination.playlist(playlist: playlist))
	}
	func goToArtist(artistId: String, artistName: String) {
		path.append(Destination.artist(artistId: artistId, artistName: artistName))
	}
	func selectPlaylist(songs: [Song]) {
		path.append(Destination.playlistSelect(songs: songs))
	}
}

enum Destination: Hashable {
	case downloads
	case login
	case albumView(albumId: String, scrollToSong: String?)
	case albumViewOffline(album: Album)
	case search
	case playlist(playlist: GetPlaylistsResponse.Playlist)
	case artist(artistId: String, artistName: String)
	case playlistSelect(songs: [Song])
}
