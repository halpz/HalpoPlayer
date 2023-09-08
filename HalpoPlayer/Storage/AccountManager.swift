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
			SubsonicClient.shared.account = account
			Task {
				do {
					_ = try await SubsonicClient.shared.authenticate()
					let data = try JSONEncoder().encode(account)
					UserDefaults.standard.set(data, forKey: "UserAccount")
				} catch {
					SubsonicClient.shared.showCode(code: 0, message: "Authentication Error: \(error)")
					throw error
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
