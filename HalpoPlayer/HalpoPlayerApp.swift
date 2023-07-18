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
	@ObservedObject var homeCoordinator = Coordinator()
	@ObservedObject var downloadsCoordinator = Coordinator()
	@ObservedObject var playlistsCoordinator = Coordinator()
	@ObservedObject var searchCoordinator = Coordinator()
	@ObservedObject var database = Database.shared
	@ObservedObject var player = AudioManager.shared
	@ObservedObject var accountHolder = AccountHolder.shared
	@ObservedObject var mediaControlBarMinimized = MediaControlBarMinimized.shared
	@ObservedObject var downloadManager = DownloadManager.shared
	@State var selectedTab: AppTab = .home
	var body: some Scene {
		WindowGroup {
			VStack {
				switch selectedTab {
				case .home:
					NavigationStack(path: $homeCoordinator.path) {
						ContentView()
							.navigationDestination(for: Destination.self) { destination in
								ViewFactory.viewForDestination(destination)
							}
					}
					.environmentObject(homeCoordinator)
				case .downloads:
					NavigationStack(path: $downloadsCoordinator.path) {
						DownloadsView()
							.navigationDestination(for: Destination.self) { destination in
								ViewFactory.viewForDestination(destination)
							}
					}
					.environmentObject(downloadsCoordinator)
				case .playlists:
					NavigationStack(path: $playlistsCoordinator.path) {
						PlaylistsView()
							.navigationDestination(for: Destination.self) { destination in
								ViewFactory.viewForDestination(destination)
							}
					}
					.environmentObject(playlistsCoordinator)
				case .search:
					NavigationStack(path: $searchCoordinator.path) {
						SearchView()
							.navigationDestination(for: Destination.self) { destination in
								ViewFactory.viewForDestination(destination)
							}
					}
					.environmentObject(searchCoordinator)
				}
				MediaControlBar()
					.gesture(DragGesture(minimumDistance: 30)
						.onEnded({ value in
							if !MediaControlBarMinimized.shared.isCompact {
								if value.translation.height > 0 {
									withAnimation {
										MediaControlBarMinimized.shared.isCompact = true
									}
								}
							}
						}))
					.environmentObject(coordinatorForTab(tab: selectedTab))
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
			.environmentObject(mediaControlBarMinimized)
			.environmentObject(accountHolder)
			.environmentObject(database)
			.environmentObject(player)
			.environmentObject(downloadManager)
			.onAppear {
				initApp()
			}
		}
	}
	func coordinatorForTab(tab: AppTab) -> Coordinator {
		switch tab {
		case .home:
			return homeCoordinator
		case .downloads:
			return downloadsCoordinator
		case .playlists:
			return playlistsCoordinator
		case .search:
			return searchCoordinator
		}
	}
	func initApp() {
		Task {
			do {
				UIApplication.shared.beginReceivingRemoteControlEvents()
				try AudioSessionController.shared.set(category: .playback)
				try AudioSessionController.shared.activateSession()
				_ = try await SubsonicClient.shared.authenticate()
			} catch {
				print(error)
			}
		}
	}
}

enum AppTab: String, CaseIterable, Hashable {
	case home, downloads, playlists, search
	var iconName: String {
		switch self {
		case .home:
			return "house"
		case .downloads:
			return "arrow.down.square"
		case .playlists:
			return "list.bullet"
		case .search:
			return "magnifyingglass"
		}
	}
}
