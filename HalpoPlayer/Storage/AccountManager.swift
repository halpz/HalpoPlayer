//
//  Account.swift
//  halpoplayer
//
//  Created by paul on 13/07/2023.
//

import Foundation

class AccountHolder: ObservableObject {
	static let shared = AccountHolder()
	var offline = false
	@Published var account: Account? {
		didSet {
			guard account != nil else { return }
//			guard !ProcessInfo.processInfo.arguments.contains("UITEST") else { return }
			SubsonicClient.shared.account = account
			Task {
				if try await SubsonicClient.shared.authenticate() {
					let data = try JSONEncoder().encode(account)
					UserDefaults.standard.set(data, forKey: "UserAccount")
					NotificationCenter.default.post(name: Notification.Name("login"), object: nil)
				}
			}
		}
	}
	init() {
		if !ProcessInfo.processInfo.arguments.contains("UITEST") {
			if let accountData = UserDefaults.standard.data(forKey: "UserAccount") {
				account = try? JSONDecoder().decode(Account.self, from: accountData)
				SubsonicClient.shared.account = account
			}
		}
	}
}
