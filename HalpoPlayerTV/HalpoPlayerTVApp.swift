//
//  HalpoPlayerTVApp.swift
//  HalpoPlayerTV
//
//  Created by paul on 11/09/2023.
//

import SwiftUI

@main
struct HalpoPlayerTVApp: App {
	@ObservedObject var accountHolder = AccountHolder.shared
    var body: some Scene {
        WindowGroup {
			NavigationStack() {
				if accountHolder.account == nil {
					LoginView()
				} else {
					TV_LibraryView()
				}
			}
        }
    }
}
