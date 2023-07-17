//
//  AirPlayView.swift
//  halpoplayer
//
//  Created by paul on 10/07/2023.
//

import SwiftUI
import UIKit
import AVKit

struct AirPlayView: UIViewRepresentable {
	
	static let shared = AirPlayView()
	
	private let routePickerView = AVRoutePickerView()
	
	private let imageView: UIImageView = {
		let iv = UIImageView()
		iv.contentMode = .scaleAspectFit
		iv.image = UIImage(systemName: "airplayaudio", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 24)))
		return iv
	}()
	
	func makeUIView(context: UIViewRepresentableContext<AirPlayView>) -> UIView {
		UIView()
	}
	
	func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<AirPlayView>) {
		
		imageView.translatesAutoresizingMaskIntoConstraints = false
		uiView.addSubview(imageView)
		
		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: uiView.topAnchor),
			imageView.leadingAnchor.constraint(equalTo: uiView.leadingAnchor),
			imageView.bottomAnchor.constraint(equalTo: uiView.bottomAnchor),
			imageView.trailingAnchor.constraint(equalTo: uiView.trailingAnchor)
		])
	}
	
	func showAirPlayMenu() {
		for view: UIView in routePickerView.subviews {
			if let button = view as? UIButton {
				button.sendActions(for: .touchUpInside)
				break
			}
		}
	}
}
