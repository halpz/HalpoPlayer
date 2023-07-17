//
//  CarPlaySceneDelegate.swift
//  halpoplayer
//
//  Created by Paul Halpin on 16/07/2023.
//

import CarPlay

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
	var interfaceController: CPInterfaceController?
	func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
		self.interfaceController = interfaceController
		let nowPlaying = CPNowPlayingTemplate.shared
		self.interfaceController?.setRootTemplate(nowPlaying, animated: true, completion: {_, _ in })
	}
	private func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnect interfaceController: CPInterfaceController) {
		self.interfaceController = nil
	}
}
