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
	@ObservedObject var accountHolder = AccountHolder.shared
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
	@ObservedObject var accountHolder = AccountHolder.shared
	func gridItems(width: Double) -> ([GridItem], Double) {
		let count = Int((width / 200.0).rounded())
		let item = GridItem(.flexible(), spacing: 8, alignment: .top)
		let itemWidth: Double = (width-(8*(Double(count)+1)))/Double(count)
		return (Array(repeating: item, count: count), itemWidth)
	}
	var body: some View {
		if UIDevice.current.userInterfaceIdiom == .pad {
			GeometryReader { geometry in
				ScrollView {
					let (gridItems, width) = gridItems(width: geometry.size.width)
					LazyVGrid(columns: gridItems, spacing: 8) {
						ForEach(viewModel.filteredAlbums) { album in
							Button {
								viewModel.albumTapped(albumId: album.id, coordinator: coordinator)
							} label: {
								AlbumGridCell(album: Album(albumListResponse: album), width: width)
							}
							.onAppear {
								viewModel.albumAppeared(album: album)
							}
						}
					}
					.padding(8)
				}
				.simultaneousGesture(DragGesture().onChanged({ value in
					withAnimation {
						MediaControlBarMinimized.shared.isCompact = true
					}
				}))
				.refreshable {
					do {
						try await viewModel.loadContent(force: true)
					} catch {
						print(error)
					}
				}
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
		} else {
			List(viewModel.albums) { album in
				Button {
					viewModel.albumTapped(albumId: album.id, coordinator: coordinator)
				} label: {
					AlbumCell(album: Album(albumListResponse: album))
				}
				.listRowSeparator(.hidden)
				.onAppear {
					viewModel.albumAppeared(album: album)
				}
			}
			.simultaneousGesture(DragGesture().onChanged({ value in
				withAnimation {
					MediaControlBarMinimized.shared.isCompact = true
				}
			}))
			.refreshable {
				do {
					try await viewModel.loadContent(force: true)
				} catch {
					print(error)
				}
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
}

struct ArtistListView: View {
	
	@StateObject var viewModel: LibraryViewModel
	@EnvironmentObject var coordinator: Coordinator
	@ObservedObject var accountHolder = AccountHolder.shared
	var body: some View {
		if viewModel.artists.isEmpty {
			ProgressView()
				.onAppear {
					Task {
						do {
							try await viewModel.loadContent(force: true)
						} catch {
							print(error)
						}
					}
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
			do {
				try await viewModel.loadContent()
			} catch {
				print(error)
			}
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
