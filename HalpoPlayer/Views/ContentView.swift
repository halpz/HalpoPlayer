//
//  ContentView.swift
//  halpoplayer
//
//  Created by paul on 07/07/2023.
//

import SwiftUI

struct ContentView: View {
	@StateObject var viewModel = ContentViewModel()
	@EnvironmentObject var coordinator: Coordinator
	@EnvironmentObject var player: AudioManager
	@EnvironmentObject var database: Database
	@EnvironmentObject var accountHolder: AccountHolder
	var body: some View {
		List(viewModel.results) { album in
			Button {
				coordinator.albumTapped( albumId: album.id)
			} label: {
				AlbumCell(album: Album(albumListResponse: album))
			}
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
		.navigationTitle("Music")
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
	}
}
