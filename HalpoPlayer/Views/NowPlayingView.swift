//
//  NowPlayingView.swift
//  HalpoPlayer
//
//  Created by paul on 24/07/2023.
//

import SwiftUI

struct NowPlayingView: View {
	@EnvironmentObject var coordinator: Coordinator
	@ObservedObject var player = AudioManager.shared
	@EnvironmentObject var compact: MediaControlBarMinimized
	@ObservedObject var timeline = TimelineManager.shared
	var buttonSize: CGFloat {
		return compact.isCompact ? 28 : 48
	}
	var body: some View {
		if player.currentSong != nil {
			if compact.isCompact {
				// COMPACT
				HStack {
					
					Button {
						withAnimation {
							compact.isCompact = false
						}
					} label: {
						HStack {
							if let image = player.albumArt {
								Image(uiImage: image)
									.resizable()
									.scaledToFill()
									.frame(width: 60, height: 60)
									.cornerRadius(8)
							}
							Text("\(player.currentSong?.title ?? "")")
								.font(.body).bold()
								.foregroundColor(.primary)
								.lineLimit(1)
						}
					}
					
					
					Button {
						if player.isPlaying {
							player.queue.pause()
						} else {
							player.queue.play()
						}
					} label: {
						if player.loading {
							ProgressView()
						} else {
							if player.isPlaying {
								Image(systemName: "pause.fill")
									.font(.system(size:buttonSize))
							} else {
								Image(systemName: "play.fill")
									.font(.system(size:buttonSize))
							}
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
				}
			} else {
				// FULL SCREEN
				
				
				VStack {
					
					Button {
						if let albumId = player.currentSong?.albumId {
							if coordinator.viewingAlbum != albumId {
								compact.isCompact = true
								coordinator.albumTapped(albumId: albumId, scrollToSong: player.currentSong?.id)
							} else {
								// scroll to current song?
							}
						}
					} label: {
						if let image = player.albumArt {
							Image(uiImage: image)
								.resizable()
								.scaledToFill()
								.frame(maxWidth: .infinity)
								.cornerRadius(8)
								.padding(16)
						}
					}
					
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
				}
			}
		} else {
			EmptyView()
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
