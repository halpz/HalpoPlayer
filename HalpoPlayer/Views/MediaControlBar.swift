//
//  MediaControlBar.swift
//  halpoplayer
//
//  Created by Paul Halpin on 08/07/2023.
//

import SwiftUI

struct MediaControlBar: View {
	@EnvironmentObject var coordinator: Coordinator
	@EnvironmentObject var player: AudioManager
	@EnvironmentObject var compact: MediaControlBarMinimized
	@ObservedObject var timeline = TimelineManager.shared
	@State private var dragAmount = CGSize.zero
	var buttonSize: CGFloat {
		return compact.isCompact ? 28 : 48
	}
	var body: some View {
		if player.currentSong != nil {
			VStack {
				HStack {
					Button {
						if compact.isCompact {
							withAnimation {
								compact.isCompact = false
							}
						} else if let albumId = player.currentSong?.albumId {
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
								.frame(width: 60, height: 60)
								.cornerRadius(8)
						}
						if compact.isCompact {
							Text("\(player.currentSong?.title ?? "")")
								.font(.body).bold()
								.foregroundColor(.primary)
								.lineLimit(1)
						} else {
							VStack(alignment: .leading) {
								Text("\(player.currentSong?.title ?? "")")
									.font(.body).bold()
									.foregroundColor(.primary)
									.multilineTextAlignment(.leading)
								Text("\(player.currentSong?.artist ?? "")")
									.font(.body)
									.foregroundColor(.secondary)
									.multilineTextAlignment(.leading)
							}
						}
						Spacer()
						if !compact.isCompact {
							AirPlayView.shared
								.frame(width: 24, height: 24)
								.padding(8)
								.onTapGesture {
									AirPlayView.shared.showAirPlayMenu()
								}
						}
					}
					if compact.isCompact {
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
				}
				if !compact.isCompact {
					HStack {
						Spacer()
						Button {
							print("back")
							self.player.previousPressed()
						} label: {
							Image(systemName: "backward.circle")
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
							if player.loading {
								ProgressView()
									.controlSize(.large)
							} else {
								if player.isPlaying {
									Image(systemName: "pause.circle")
										.font(.system(size:buttonSize))
								} else {
									Image(systemName: "play.circle")
										.font(.system(size:buttonSize))
								}
							}
						}
						.padding()
						Button {
							try? self.player.queue.next()
						} label: {
							Image(systemName: "forward.circle")
								.font(.system(size:buttonSize))
						}
						.padding()
						.disabled(self.player.queue.nextItems.isEmpty)
						
						Spacer()
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
			.padding()
			.background {
				Color("TextBackground")
			}
			.gesture(
				DragGesture(minimumDistance: 30)
					.onEnded { value in
						if !compact.isCompact {
							if value.translation.height > 0 {
								withAnimation {
									compact.isCompact = true
								}
							}
						}
					}
			)
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

class MediaControlBarMinimized: ObservableObject {
	static let shared = MediaControlBarMinimized()
	@Published var isCompact = false
}
