//
//  ArtistView.swift
//  HalpoPlayer
//
//  Created by paul on 20/07/2023.
//

import SwiftUI

struct ArtistView: View {
	@EnvironmentObject var coordinator: Coordinator
	@StateObject var viewModel: ArtistViewModel
	init(artistId: String, artistName: String) {
		_viewModel = StateObject(wrappedValue: ArtistViewModel(artistId: artistId, artistName: artistName))
	}
	var body: some View {
		List {
			Text(viewModel.artistName).font(.largeTitle)
			HStack {
				Spacer()
				if let image = viewModel.image {
					Image(uiImage: image)
						.resizable()
						.scaledToFit()
						.frame(width: 200, height: 200)
						.clipShape(Circle())
				}
				Spacer()
			}
			.padding()
			.listRowSeparator(.hidden)
			if let bio = viewModel.bio {
				let markdown = LocalizedStringKey(stringLiteral: bio)
				ExpandableText(markdown)
					.font(.body).lineSpacing(4)
					.padding(8)
					.background(Color("TextBackground"))
					.cornerRadius(8)
			}
			ForEach(viewModel.albums ?? []) { album in
				Button {
					coordinator.albumTapped(albumId: album.id, scrollToSong: nil)
				} label: {
					AlbumCell(album: album, showArtistName: false)
				}
				.listRowSeparator(.hidden)
			}
		}
		.refreshable {
			viewModel.loadData()
		}
		.listStyle(.plain)
		.toolbar {
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
