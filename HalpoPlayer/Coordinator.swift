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
	func albumTapped(albumId: String) {
		path.append(Destination.albumView(albumId: albumId))
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
}

enum Destination: Hashable {
	case downloads
	case login
	case albumView(albumId: String)
	case albumViewOffline(album: Album)
	case search
}

class ViewFactory {
	@ViewBuilder
	class func viewForDestination(_ destination: Destination) -> some View {
		switch destination {
		case .albumView(let albumId):
			AlbumDetailView(albumId: albumId)
		case .downloads:
			DownloadsView()
		case .login:
			let account = AccountHolder.shared.account
			LoginView(address: account?.address ?? "",
					  otherAddress: account?.otherAddress ?? "",
					  username: account?.username ?? "",
					  password: account?.password ?? "")
		case .search:
			SearchView()
		case .albumViewOffline(let album):
			OfflineAlbumView(album: album)
		}
	}
}
