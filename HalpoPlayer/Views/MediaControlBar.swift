//
//  MediaControlBar.swift
//  halpoplayer
//
//  Created by Paul Halpin on 08/07/2023.
//

import SwiftUI

struct MediaControlBar: View {
	@EnvironmentObject var coordinator: Coordinator
	@ObservedObject var player = AudioManager.shared
	@ObservedObject var timeline = TimelineManager.shared
	@State private var dragAmount = CGSize.zero
	var buttonSize: CGFloat = 28
	var body: some View {
		if player.currentSong != nil {
			VStack {
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
					Spacer()
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
			.padding()
			.background {
				Color("TextBackground")
			}
			.gesture(
				DragGesture(minimumDistance: 30)
					.onEnded { value in
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

