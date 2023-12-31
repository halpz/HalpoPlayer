//
//  HalpoPlayerApp.swift
//  HalpoPlayer
//
//  Created by paul on 17/07/2023.
//

import SwiftUI
import SwiftAudioEx

@main
struct halpoplayerApp: App {
	@ObservedObject var libraryCoordinator = Coordinator()
	@ObservedObject var downloadsCoordinator = Coordinator()
	@ObservedObject var playlistsCoordinator = Coordinator()
	@ObservedObject var searchCoordinator = Coordinator()
	@State var selectedTab: AppTab = .library
	@State var presentNowPlayingView = false
	let batteryManager = BatteryManager.shared
	var body: some Scene {
		WindowGroup {
			VStack {
				switch selectedTab {
				case .library:
					NavigationStack(path: $libraryCoordinator.path) {
						LibraryView()
							.navigationDestination(for: Destination.self) { destination in
								ViewFactory.viewForDestination(destination)
							}
					}
				case .downloads:
					NavigationStack(path: $downloadsCoordinator.path) {
						DownloadsView()
							.navigationDestination(for: Destination.self) { destination in
								ViewFactory.viewForDestination(destination)
							}
					}
				case .playlists:
					NavigationStack(path: $playlistsCoordinator.path) {
						PlaylistsView()
							.navigationDestination(for: Destination.self) { destination in
								ViewFactory.viewForDestination(destination)
							}
					}
				case .search:
					NavigationStack(path: $searchCoordinator.path) {
						SearchView()
							.navigationDestination(for: Destination.self) { destination in
								ViewFactory.viewForDestination(destination)
							}
					}
				}
				MediaControlBar()
					.onTapGesture {
						self.presentNowPlayingView.toggle()
					}
					.sheet(isPresented: $presentNowPlayingView, content: {
						NowPlayingView(goToAlbum: { albumId, songId in
							if self.coordinatorForTab(tab: self.selectedTab).viewingAlbum != albumId {
								self.coordinatorForTab(tab: self.selectedTab).albumTapped(albumId: albumId, scrollToSong: songId)
							}
						}, goToArtist: { artistId, artistName in
							self.coordinatorForTab(tab: self.selectedTab).goToArtist(artistId: artistId, artistName: artistName)
						}, addToPlaylist: { song in
							self.coordinatorForTab(tab: self.selectedTab).selectPlaylist(songs: [song])
						})
					})
					
				HStack {
					ForEach(AppTab.allCases, id: \.self) { tab in
						Spacer()
						Button {
							if tab == selectedTab {
								let coordinator = self.coordinatorForTab(tab: tab)
								coordinator.path.removeLast(coordinator.path.count)
							} else {
								selectedTab = tab
							}
						} label: {
							Image(systemName: tab.iconName)
								.font(.system(size: 24))
								.foregroundColor(selectedTab == tab ? .accentColor : .primary)
						}
						.padding(8)
						if tab == AppTab.allCases.last {
							Spacer()
						}
					}
				}
				.frame(maxWidth: .infinity)
			}
			.ignoresSafeArea(.keyboard)
			.environmentObject(coordinatorForTab(tab: selectedTab))
			.onAppear {
				initApp()
			}
		}
	}
	func coordinatorForTab(tab: AppTab) -> Coordinator {
		switch tab {
		case .library:
			return libraryCoordinator
		case .downloads:
			return downloadsCoordinator
		case .playlists:
			return playlistsCoordinator
		case .search:
			return searchCoordinator
		}
	}
	func initApp() {
		UIApplication.shared.beginReceivingRemoteControlEvents()
	}
}

enum AppTab: String, CaseIterable, Hashable {
	case library, downloads, playlists, search
	var iconName: String {
		switch self {
		case .library:
			return "books.vertical"
		case .downloads:
			return "arrow.down.square"
		case .playlists:
			return "list.bullet"
		case .search:
			return "magnifyingglass"
		}
	}
}
