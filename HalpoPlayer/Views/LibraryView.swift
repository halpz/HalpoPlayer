//
//  LibraryView.swift
//  halpoplayer
//
//  Created by paul on 07/07/2023.
//

import SwiftUI

struct LibraryView: View {
	@StateObject var viewModel = LibraryViewModel()
	@EnvironmentObject var coordinator: Coordinator
	@EnvironmentObject var database: Database
	@EnvironmentObject var accountHolder: AccountHolder
	var body: some View {
		if accountHolder.account != nil {
			switch viewModel.viewType {
			case .artists:
				ArtistListView(viewModel: viewModel)
			case .albums:
				AlbumListView(viewModel: viewModel)
			}
		} else {
			Button {
				coordinator.goToLogin()
			} label: {
				Text("Log in")
					.font(.largeTitle)
			}
			.buttonStyle(.borderedProminent)
		}
	}
}

struct AlbumListView: View {
	@Environment(\.horizontalSizeClass) var horizontalSize
	@StateObject var viewModel: LibraryViewModel
	@EnvironmentObject var coordinator: Coordinator
	@EnvironmentObject var database: Database
	@EnvironmentObject var accountHolder: AccountHolder
	var gridItems: [GridItem] {
		if horizontalSize == .compact {
			return [GridItem(.flexible(), spacing: 8),GridItem(.flexible(), spacing: 8)]
		} else {
			return [GridItem(.flexible(), spacing: 8),GridItem(.flexible(), spacing: 8),GridItem(.flexible(), spacing: 8),GridItem(.flexible(), spacing: 8)]
		}
	}
	var body: some View {
		ScrollView {
			LazyVGrid(columns: gridItems, spacing: 8) {
				ForEach(viewModel.albums) { album in
					Button {
						viewModel.albumTapped(albumId: album.id, coordinator: coordinator)
					} label: {
						AlbumGridCell(album: Album(albumListResponse: album))
					}
					.frame(height: 260)
				}
			}
			.padding(8)
		}
		
//		List(viewModel.albums) { album in
//			Button {
//				viewModel.albumTapped(albumId: album.id, coordinator: coordinator)
//			} label: {
//				AlbumCell(album: Album(albumListResponse: album))
//			}
//			.listRowSeparator(.hidden)
//		}
		.simultaneousGesture(DragGesture().onChanged({ value in
			withAnimation {
				MediaControlBarMinimized.shared.isCompact = true
			}
		}))
		.refreshable {
			viewModel.refresh()
		}
		.listStyle(.plain)
		.searchable(text: $viewModel.searchText, prompt: "Search albums")
		.scrollDismissesKeyboard(.immediately)
		.navigationBarTitleDisplayMode(.inline)
		.navigationTitle(viewModel.viewType.rawValue.capitalized)
		.toolbar {
			ToolbarTitleMenu {
				Picker("Picker", selection: $viewModel.viewType) {
					ForEach(LibraryViewType.allCases, id: \.self) { item in
						Text(item.rawValue.capitalized)
					}
				}
			}
			ToolbarItem(placement: .navigationBarLeading) {
				Button {
					viewModel.goToLogin(coordinator: coordinator)
				} label: {
					Image(systemName: "person.circle").imageScale(.large)
				}
			}
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

struct ArtistListView: View {
	@StateObject var viewModel: LibraryViewModel
	@EnvironmentObject var coordinator: Coordinator
	@EnvironmentObject var database: Database
	@EnvironmentObject var accountHolder: AccountHolder
	var body: some View {
		if viewModel.artists.isEmpty {
			ProgressView()
				.onAppear {
					viewModel.loadContent()
				}
		}
		List(viewModel.artists) { artist in
			Button {
				coordinator.goToArtist(artistId: artist.id, artistName: artist.name)
			} label: {
				ArtistCell(artist: artist)
			}
			.listRowSeparator(.hidden)
		}
		.simultaneousGesture(DragGesture().onChanged({ value in
			withAnimation {
				MediaControlBarMinimized.shared.isCompact = true
			}
		}))
		.refreshable {
			viewModel.refresh()
		}
		.listStyle(.plain)
		.searchable(text: $viewModel.searchText, prompt: "Search artists")
		.scrollDismissesKeyboard(.immediately)
		.navigationBarTitleDisplayMode(.inline)
		.navigationTitle(viewModel.viewType.rawValue.capitalized)
		.toolbar {
			ToolbarTitleMenu {
				Picker("Picker", selection: $viewModel.viewType) {
					ForEach(LibraryViewType.allCases, id: \.self) { item in
						Text(item.rawValue.capitalized)
					}
				}
			}
			ToolbarItem(placement: .navigationBarLeading) {
				Button {
					viewModel.goToLogin(coordinator: coordinator)
				} label: {
					Image(systemName: "person.circle").imageScale(.large)
				}
			}
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
