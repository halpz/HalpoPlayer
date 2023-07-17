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
		// Create a list
		let item = CPListItem(text: "title", detailText: "detail")
		item.accessoryType = .disclosureIndicator
		let section = CPListSection(items: [item])
		let listTemplate = CPListTemplate(title: "Section", sections: [section])
		// Set root
		self.interfaceController?.setRootTemplate(listTemplate, animated: true, completion: {_, _ in })
	}
	// CarPlay disconnected
	private func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnect interfaceController: CPInterfaceController) {
		self.interfaceController = nil
	}
}
