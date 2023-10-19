//
//  ViewFactory.swift
//  HalpoPlayer
//
//  Created by paul on 12/09/2023.
//

import SwiftUI

class ViewFactory {
	@ViewBuilder
	class func viewForDestination(_ destination: Destination) -> some View {
		switch destination {
		case .albumView(let albumId, let scrollToSong):
			AlbumDetailView(albumId: albumId, scrollToSong: scrollToSong)
		case .downloads:
			DownloadsView()
		case .login:
			AccountListView()
		case .search:
			SearchView()
		case .albumViewOffline(let album):
			OfflineAlbumView(album: album)
		case .playlist(let playlist):
			PlaylistView(playlist: playlist)
		case .artist(let id, let artistName):
			ArtistView(artistId: id, artistName: artistName)
		case .playlistSelect(let songs):
			PlaylistsView(songs, refresh: true)
		}
	}
}
