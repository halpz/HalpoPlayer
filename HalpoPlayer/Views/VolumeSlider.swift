//
//  VolumeSlider.swift
//  HalpoPlayer
//
//  Created by paul on 13/10/2023.
//

import SwiftUI
import MediaPlayer
import UIKit

struct VolumeSlider: UIViewRepresentable {
	func makeUIView(context: Context) -> MPVolumeView {
		let slider = MPVolumeView(frame: .zero)
		for v in slider.subviews where v is UISlider {
			let slider = v as? UISlider
			slider?.thumbTintColor = .clear
		}
		return slider
	}
	
	func updateUIView(_ view: MPVolumeView, context: Context) {}
}
