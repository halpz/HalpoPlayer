//
//  AlbumsView.swift
//  halpoplayer
//
//  Created by paul on 07/07/2023.
//

import SwiftUI

struct AlbumsView: View {
	@StateObject var viewModel = ContentViewModel()
	@EnvironmentObject var coordinator: Coordinator
	@EnvironmentObject var database: Database
	@EnvironmentObject var accountHolder: AccountHolder
	var body: some View {
		if accountHolder.account != nil {
			List(viewModel.results) { album in
				Button {
					viewModel.albumTapped(albumId: album.id, coordinator: coordinator)
				} label: {
					AlbumCell(album: Album(albumListResponse: album))
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
			.searchable(text: $viewModel.searchText, prompt: "Search albums")
			.scrollDismissesKeyboard(.immediately)
			.navigationTitle("Albums")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
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