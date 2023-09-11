//
//  ContentView.swift
//  HalpoPlayerTV
//
//  Created by paul on 11/09/2023.
//

import SwiftUI

struct TV_LibraryView: View {
	let spacing: Double = 32
	@StateObject var viewModel = TV_LibraryViewModel()
	func gridItems(width: Double) -> ([GridItem], Double) {
		let count = Int((width / 300.0).rounded())
		let item = GridItem(.flexible(), spacing: spacing, alignment: .top)
		let itemWidth: Double = (width-(spacing*(Double(count)+1)))/Double(count)
		return (Array(repeating: item, count: count), itemWidth)
	}
    var body: some View {
		GeometryReader { proxy in
			ScrollView {
				let (columns, width) = self.gridItems(width: proxy.size.width)
				LazyVGrid(columns: columns, spacing: spacing) {
					ForEach(viewModel.albums) { a in
						let album = Album(albumListResponse: a)
						Button {
							print(a.name)
						} label: {
							AlbumGridCell(album: album, width: width)
								.onAppear {
									viewModel.albumAppeared(album: album)
								}
						}
						.buttonStyle(.plain)
					}
				}
				.padding(spacing)
			}
		}
    }
}

class TV_LibraryViewModel: ObservableObject {
	@Published var albums: [GetAlbumListResponse.Album] = []
	var albumPage = 0
	var currentTask: Task<(), Error>?
	init() {
		loadAlbums()
	}
	func loadAlbums() {
		Task {
			do {
				let albs = try await SubsonicClient.shared.getAlbumList(page: 0)
				await MainActor.run {
					self.albums = albs.subsonicResponse.albumList.album
					self.albumPage = 1
				}
			} catch {
				print(error)
			}
		}
	}
	func loadNextPageAlbums() async throws {
		currentTask?.cancel()
		currentTask = Task {
			let albs = try await SubsonicClient.shared.getAlbumList(page: self.albumPage)
			await MainActor.run {
				self.albums += albs.subsonicResponse.albumList.album
				self.albumPage += 1
			}
		}
	}
	func albumAppeared(album: Album) {
		if album.id == albums.last?.id {
			Task {
				try await self.loadNextPageAlbums()
			}
		}
	}
}
