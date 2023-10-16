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
	
	class SystemVolumeView: MPVolumeView {
		override func volumeSliderRect(forBounds bounds: CGRect) -> CGRect {
			var newBounds = super.volumeSliderRect(forBounds: bounds)
			newBounds.origin.y = bounds.origin.y
			newBounds.size.height = bounds.size.height
			return newBounds
		}
		override func volumeThumbRect(forBounds bounds: CGRect, volumeSliderRect rect: CGRect, value: Float) -> CGRect {
			var newBounds = super.volumeThumbRect(forBounds: bounds, volumeSliderRect: rect, value: value)
			newBounds.origin.y = bounds.origin.y
			newBounds.size.height = bounds.size.height
			return newBounds
		}
	}
	
	func makeUIView(context: Context) -> SystemVolumeView {
		let slider = SystemVolumeView(frame: .zero)
		for v in slider.subviews where v is UISlider {
			let slider = v as? UISlider
			slider?.thumbTintColor = .clear
		}
		return slider
	}
	
	func updateUIView(_ view: SystemVolumeView, context: Context) {}
}
