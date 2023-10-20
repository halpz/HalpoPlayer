//
//  NowPlayingView.swift
//  HalpoPlayer
//
//  Created by paul on 24/07/2023.
//

import SwiftUI

struct NowPlayingView: View {
	@Environment(\.dismiss) var dismiss
	@ObservedObject var player = AudioManager.shared
	@ObservedObject var timeline = TimelineManager.shared
	@State var volume: Float = AudioManager.shared.queue.volume
	var goToAlbum: (((albumId: String, songId: String?)) -> Void)?
	var goToArtist: (((artistId: String, artistName: String)) -> Void)?
	var buttonSize: CGFloat = 32
	var playButtonName: String {
		if player.isPlaying {
			return "pause.circle.fill"
		} else {
			return "play.circle.fill"
		}
	}
	func playButtonPressed() {
		if player.isPlaying {
			self.player.queue.pause()
		} else {
			self.player.queue.play()
		}
	}
	var body: some View {
		VStack {
			Spacer()
				.frame(height: 64)
			Button {
				if let albumId = player.currentSong?.albumId {
					self.dismiss()
					self.goToAlbum?((albumId, player.currentSong?.id))
				}
			} label: {
				if let image = player.albumArt {
					HStack {
						Spacer()
						ZStack {
							Image(uiImage: image)
								.resizable()
								.scaledToFit()
								.cornerRadius(8)
								.frame(maxWidth: 300, maxHeight: 300)
								.shadow(radius: 8)
							if player.loading {
								ProgressView()
									.controlSize(.large)
							}
						}
						Spacer()
					}
				}
			}
			Spacer()
				.frame(height: 16)
			VStack(spacing: 8) {
				Text(player.currentSong?.title ?? "")
					.font(.title)
					.multilineTextAlignment(.center)
				Button {
					if let artistId = player.currentSong?.artistId,
					   let artistName = player.currentSong?.artist {
						self.dismiss()
						self.goToArtist?((artistId, artistName))
					}
				} label: {
					Text(player.currentSong?.artist ?? "")
						.font(.body)
						.multilineTextAlignment(.center)
				}
				.disabled(player.currentSong?.artistId == nil)
			}
			.padding([.leading, .trailing], 16)
			Spacer()
			let upperBound = getUpperBound()
			HStack {
				Text(timeString(time:TimeInterval(timeline.timeElapsed)))
					.foregroundColor(.secondary)
					.font(.callout)
					.padding(4)
				ZStack {
					let duration = max(0, min(timeline.duration, upperBound))
					ProgressView(value: duration, total: upperBound)
					Slider(value: $timeline.timeElapsed, in: 0...upperBound) { didChange in
						player.invalidateSlider = didChange
						if didChange {
							player.queue.pause()
						} else {
							player.queue.seek(to: timeline.timeElapsed)
							player.queue.play()
						}
					}
					.tint(nil)
					.opacity(0.8)
				}
				Text(timeString(time:TimeInterval(0 - self.getUpperBound() + timeline.timeElapsed)))
					.foregroundColor(.secondary)
					.font(.callout)
					.padding(4)
			}
			.padding(16)
			HStack {
				Spacer()
				Button {
					print("back")
					do {
						try self.player.previousPressed()
					} catch {
						print(error)
					}
				} label: {
					Image(systemName: "backward.fill")
						.font(.system(size: buttonSize))
				}
				.padding()
				.disabled(self.player.queue.previousItems.isEmpty && self.player.queue.currentTime < 5)
				
				Button {
					if player.isPlaying {
						player.queue.pause()
					} else {
						player.queue.play()
					}
				} label: {
					if player.isPlaying {
						Image(systemName: "pause.fill")
							.font(.system(size:buttonSize))
					} else {
						Image(systemName: "play.fill")
							.font(.system(size:buttonSize))
					}
				}
				.padding()
				Button {
					try? self.player.queue.next()
				} label: {
					Image(systemName: "forward.fill")
						.font(.system(size:buttonSize))
				}
				.padding()
				.disabled(self.player.queue.nextItems.isEmpty)
				
				Spacer()
			}
			HStack {
				Image(systemName: "speaker")
					.foregroundStyle(.gray)
				VolumeSlider()
				Image(systemName: "speaker.wave.3")
					.foregroundStyle(.gray)
			}
			.frame(height: 40)
			.padding(.horizontal)
			HStack {
				Spacer()
				AirPlayView.shared
					.frame(width: 24, height: 24)
					.padding(8)
					.onTapGesture {
						AirPlayView.shared.showAirPlayMenu()
					}
				Spacer()
			}
		}
	}
	func getUpperBound() -> Double {
		if let duration = player.currentSong?.duration,
		   duration > 0 {
			return Double(duration)
		} else {
			return timeline.duration > 0 ? timeline.duration : 1
		}
	}
	func timeString(time: TimeInterval) -> String {
		let negative: String = time < 0 ? "-" : ""
		let safeTime = abs(time)
		let hours = Int(safeTime) / 3600
		let minutes = Int(safeTime) / 60 % 60
		let seconds = Int(safeTime) % 60
		if hours > 0 {
			return negative + String(format:"%02i:%02i:%02i", hours, minutes, seconds)
		} else {
			return negative + String(format:"%02i:%02i", minutes, seconds)
		}
	}
}
