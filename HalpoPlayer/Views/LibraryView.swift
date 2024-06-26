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
			ZStack {
				switch viewModel.viewType {
				case .artists:
					ArtistListView(viewModel: viewModel)
				case .albums:
					AlbumListView(viewModel: viewModel)
						.onAppear {
							if viewModel.albums.isEmpty {
								Task {
									do {
										try await viewModel.loadContent(force: true)
									} catch {
										print(error)
									}
								}
								
							}
						}
				}
				if viewModel.loading {
					VStack {
						Spacer()
						Text("Loading...")
							.font(.title)
						Spacer()
					}
				}
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
	@ObservedObject var database = Database.shared
	func gridItems(width: Double) -> ([GridItem], Double) {
		let count = Int((width / 200.0).rounded())
		let item = GridItem(.flexible(), spacing: 8, alignment: .top)
		let itemWidth: Double = (width-(8*(Double(count)+1)))/Double(count)
		return (Array(repeating: item, count: count), itemWidth)
	}
	var body: some View {
		if database.libraryLayout == .grid {
			GeometryReader { geometry in
				ScrollView {
					let (gridItems, width) = gridItems(width: geometry.size.width)
					LazyVGrid(columns: gridItems, spacing: 8) {
						ForEach(viewModel.filteredAlbums) { album in
							Button {
								viewModel.albumTapped(album: album, coordinator: coordinator)
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
				.onChange(of: self.database.libraryAlbumSortType) { _ in
					Task {
						do {
							try await self.viewModel.loadContent(force: true)
						} catch {
							print(error)
						}
					}
				}
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
					ToolbarItem(placement: .navigationBarTrailing) {
						Menu {
							Section {
								Picker("Layout", selection: $database.libraryLayout) {
									ForEach(LibraryLayout.allCases, id: \.self) { layout in
										Label(layout.rawValue.capitalized, systemImage: layout.iconName)
									}
								}
							}
							Section {
								Picker("Sort order", selection: $database.libraryAlbumSortType) {
									ForEach(AlbumSortType.allCases, id: \.self) { sortType in
										Text(sortType.title)
									}
								}
							}
						} label: {
							Image(systemName: "ellipsis.circle").imageScale(.large)
						}
					}
				}
			}
		} else {
			List(viewModel.filteredAlbums) { album in
				Button {
					if viewModel.selectMode {
						if viewModel.selectedAlbums.contains(album) {
							viewModel.selectedAlbums.removeAll { $0.id == album.id }
						} else {
							viewModel.selectedAlbums.append(album)
						}
					} else {
						viewModel.albumTapped(album: album, coordinator: coordinator)
					}
				} label: {
					ZStack {
						AlbumCell(album: Album(albumListResponse: album))
						if viewModel.selectedAlbums.contains(album) {
							Rectangle()
								.fill(.green.opacity(0.5))
						}
					}
				}
				.listRowSeparator(.hidden)
				.onAppear {
					viewModel.albumAppeared(album: album)
				}
			}
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
			.onChange(of: self.database.libraryAlbumSortType) { _ in
				Task {
					do {
						try await self.viewModel.loadContent(force: true)
					} catch {
						print(error)
					}
				}
			}
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
				if viewModel.selectMode {
					ToolbarItem(placement: .navigationBarTrailing) {
						Button {
							viewModel.addToPlaylist(coordinator: coordinator)
						} label: {
							Text("Add to...")
						}
					}
				} else {
					ToolbarItem(placement: .navigationBarTrailing) {
						Button {
							viewModel.shuffle()
						} label: {
							Image(systemName: "shuffle").imageScale(.large)
						}
					}
				}
				ToolbarItem(placement: .navigationBarTrailing) {
					Menu {
						Section {
							Picker("Layout", selection: $database.libraryLayout) {
								ForEach(LibraryLayout.allCases, id: \.self) { layout in
									Label(layout.rawValue.capitalized, systemImage: layout.iconName)
								}
							}
						}
						Section {
							Picker("Sort order", selection: $database.libraryAlbumSortType) {
								ForEach(AlbumSortType.allCases, id: \.self) { sortType in
									Text(sortType.title)
								}
							}
						}
					} label: {
						Image(systemName: "ellipsis.circle").imageScale(.large)
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
		List(viewModel.filteredArtists) { artist in
			Button {
				coordinator.goToArtist(artistId: artist.id, artistName: artist.name)
			} label: {
				ArtistCell(artist: artist)
			}
			.listRowSeparator(.hidden)
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

enum LibraryLayout: String, CaseIterable {
	case list, grid
	var iconName: String {
		switch self {
		case .list:
			return "line.3.horizontal"
		case .grid:
			return "square.grid.2x2"
		}
	}
}
