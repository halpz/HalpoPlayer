//
//  PlaylistCell.swift
//  HalpoPlayer
//
//  Created by paul on 18/07/2023.
//

import SwiftUI

struct PlaylistCell: View {
	var playlist: GetPlaylistsResponse.Playlist
	var body: some View {
		HStack {
			Text(playlist.name)
			Spacer()
			Image(systemName: "chevron.right")
				.font(.body)
		}
	}
}
