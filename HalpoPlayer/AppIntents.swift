//
//  AppIntents.swift
//  HalpoPlayer
//
//  Created by paul on 24/10/2023.
//

import Foundation
import AppIntents

struct PlayRandomSongs: AppIntent {
	static var title: LocalizedStringResource = "Shuffle music"
	static var description: IntentDescription = IntentDescription(stringLiteral: "Shuffles and plays your music library (if logged in)")
	static var openAppWhenRun: Bool = true
	func perform() async throws -> some IntentResult {
		try await shuffle()
		return .result()
	}
	func shuffle() async throws {
		let response = try await SubsonicClient.shared.getRandomSongs()
		let songs = response.subsonicResponse.randomSongs.song.compactMap {
			return Song(randomSong: $0)
		}
		DispatchQueue.main.async {
			AudioManager.shared.play(songs: songs, index: 0)
		}
	}
}
