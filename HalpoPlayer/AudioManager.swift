//
//  AudioManager.swift
//  halpoplayer
//
//  Created by paul on 10/07/2023.
//

import SwiftAudioEx
import MediaPlayer

class TimelineManager: ObservableObject {
	static let shared = TimelineManager()
	@Published var timeElapsed = 0.0
	@Published var duration = 0.0
	@Published var percentPlayed = 0.0
}

class AudioManager: ObservableObject {
	static let shared = AudioManager()
	var currentTask: Task<(), Error>?
	@Published var songs: [Song]?
	@Published var queue = QueuedAudioPlayer()
	@Published var currentSong: Song?
	@Published var isPlaying = false
	@Published var albumArt: UIImage?
	var invalidateSlider = false
	@Published var loading = false
	
	init() {
		self.queue.event.queueIndex.addListener(self, handleAudioPlayerIndexChange)
		self.queue.event.stateChange.addListener(self, handleAudioPlayerStateChange)
		self.queue.event.secondElapse.addListener(self, handleAudioPlayerSecondElapse)
		self.queue.event.updateDuration.addListener(self, handleAudioPlayerUpdateDuration)
		self.queue.remoteCommandController.handlePreviousTrackCommand = handlePreviousTrackCommand
		self.queue.event.fail.addListener(self, handleAudioPlayerError)
		self.queue.remoteCommands = [
			.play,
			.pause,
			.changePlaybackPosition,
			.next,
			.previous
		]
	}
	
	func play(songs: [Song], index: Int) {
		self.activateSession { success in
			guard success else { return }
			self.queue.stop()
			for (i, _) in self.queue.items.enumerated() {
				try? self.queue.removeItem(at: i)
			}
			self.songs = []
			songs.forEach {
				self.addSongToQueue(song: $0)
			}
			try? self.queue.jumpToItem(atIndex: index, playWhenReady: true)
			self.currentSong = songs[index]
		}
	}
	
	func activateSession(callback: @escaping (Bool) -> Void) {
		do {
			if !AudioSessionController.shared.audioSessionIsActive {
				try AudioSessionController.shared.set(category: .playback)
				try AudioSessionController.shared.activateSession()
				AudioSessionController.shared.delegate = self
			}
			callback(true)
		} catch {
			print("Could not activate audio session")
			callback(false)
		}
	}
	
	func addSongToQueue(song: Song) {
		self.songs?.append(song)
		let item: DefaultAudioItem
		if let cachedURL = Database.shared.retrieveSong(song: song) {
			item = DefaultAudioItem(audioUrl: cachedURL.path(), sourceType: .file)
		} else {
			let url = SubsonicClient.shared.stream(id: song.id, mp3: true).absoluteString
			item = DefaultAudioItem(audioUrl: url, sourceType: .stream)
		}
		item.albumTitle = song.album
		item.artist = song.artist
		item.title = song.title
		item.artwork = albumArt
		try? self.queue.add(item: item)
	}
	
	func handleAudioPlayerError(fail: AudioPlayer.FailEventData) {
		if let fail = fail {
			print("AUDIO PLAYER ERROR: \(fail.localizedDescription)")
		}
	}
	
	func handleAudioPlayerUpdateDuration(time: AudioPlayer.SecondElapseEventData) {
		guard !invalidateSlider else { return }
		DispatchQueue.main.async {
			TimelineManager.shared.duration = time
			TimelineManager.shared.percentPlayed = (TimelineManager.shared.timeElapsed / TimelineManager.shared.duration) * 100
		}
	}
	
	func handleAudioPlayerSecondElapse(time: AudioPlayer.SecondElapseEventData) {
		guard !invalidateSlider else { return }
		DispatchQueue.main.async {
			TimelineManager.shared.timeElapsed = time
			TimelineManager.shared.percentPlayed = (TimelineManager.shared.timeElapsed / TimelineManager.shared.duration) * 100
		}
	}
	
	func handleAudioPlayerStateChange(state: AudioPlayer.StateChangeEventData) {
		DispatchQueue.main.async {
			switch state {
			case .playing:
				self.isPlaying = true
			case .loading:
				self.loading = true
			case .ready:
				self.loading = false
			default:
				self.isPlaying = false
			}
		}
	}
	
	func handleAudioPlayerIndexChange(state: AudioPlayer.QueueIndexEventData) {
		DispatchQueue.main.async {
			self.currentSong = self.songs?[state.newIndex ?? 0]
			Task {
				let image = try await SubsonicClient.shared.coverArt(albumId: self.currentSong?.albumId ?? "")
				let media = MPMediaItemArtwork(boundsSize: CGSize(width: 100, height: 100)) { _ in
					return image
				}
				self.queue.nowPlayingInfoController.set(keyValue: MediaItemProperty.artwork(media))
				DispatchQueue.main.async {
					self.albumArt = image
				}
			}
		}
	}
	func previousPressed() throws {
		if self.queue.currentTime < 5 {
			try self.queue.previous()
		} else {
			self.queue.seek(to: 0)
		}
	}
	
	func handlePreviousTrackCommand(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
		do {
			try previousPressed()
			return MPRemoteCommandHandlerStatus.success
		}
		catch {
			return MPRemoteCommandHandlerStatus.commandFailed
		}
	}
}

extension AudioManager: AudioSessionControllerDelegate {
	func handleInterruption(type: InterruptionType) {
		switch type {
		case .began:
			self.queue.pause()
		case .ended(let shouldResume):
			if shouldResume {
				self.queue.play()
			}
		}
	}
}
