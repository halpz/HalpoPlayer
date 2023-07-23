//
//  BatteryManager.swift
//  HalpoPlayer
//
//  Created by Paul Halpin on 23/07/2023.
//

import UIKit

class BatteryManager: ObservableObject {
	@Published var state: UIDevice.BatteryState
	static let shared = BatteryManager()
	private init() {
		UIDevice.current.isBatteryMonitoringEnabled = true
		state = UIDevice.current.batteryState
		UIApplication.shared.isIdleTimerDisabled = state == .full || state == .charging
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(batteryStateDidChange),
			name: UIDevice.batteryStateDidChangeNotification,
			object: nil
		)
	}
	deinit {
		NotificationCenter.default.removeObserver(
			self,
			name: UIDevice.batteryStateDidChangeNotification,
			object: nil
		)
	}
	@objc private func batteryStateDidChange() {
		DispatchQueue.main.async {
			self.state = UIDevice.current.batteryState
		}
		UIApplication.shared.isIdleTimerDisabled = state == .full || state == .charging
	}
}
