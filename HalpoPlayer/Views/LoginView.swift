//
//  LoginView.swift
//  halpoplayer
//
//  Created by paul on 10/07/2023.
//

import SwiftUI

struct LoginView: View {
	@Environment(\.dismiss) var dismiss
	@ObservedObject var accountHolder = AccountHolder.shared
	@State var address: String = ""
	@State var otherAddress: String = ""
	@State var username: String = ""
	@State var password: String = ""
	@State var port: String = "4533"
	var body: some View {
		Form {
			TextField("URL", text: $address)
				.keyboardType(.URL)
				.autocorrectionDisabled(true)
				.textInputAutocapitalization(.never)
			TextField("Alternative URL", text: $otherAddress)
				.keyboardType(.URL)
				.autocorrectionDisabled(true)
				.textInputAutocapitalization(.never)
			TextField("Port", text: $port)
				.keyboardType(.numberPad)
				.autocorrectionDisabled(true)
				.textInputAutocapitalization(.never)
			TextField("Username", text: $username)
				.keyboardType(.alphabet)
				.textInputAutocapitalization(.never)
				.autocorrectionDisabled(true)
			SecureField("Password", text: $password)
				.keyboardType(.alphabet)
				.textInputAutocapitalization(.never)
				.autocorrectionDisabled(true)
			Button("Save") {
				submit()
			}
			.buttonStyle(.automatic)
		}
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button {
					// log out
					self.logout()
				} label: {
					Text("Log out")
				}
			}
		}
	}
	func submit() {
		print("done")
		Task {
			if !address.contains("http://") && !address.contains("https://") {
				address = "http://" + address
			}
			if !otherAddress.contains("http://") && !otherAddress.contains("https://") {
				otherAddress = "http://" + otherAddress
			}
			if ProcessInfo.processInfo.arguments.contains("UITEST") {
				username = "app"
				password = "app"
				address = "http://paulhalpin.co.uk"
			}
			SubsonicClient.shared.testAddressesForPermission(ad1: address, ad2: otherAddress) { success in
				guard success else {
					SubsonicClient.shared.showCode(code: 0, message: "Could not ping either address\n\(address)\n\(otherAddress)")
					return}
				let account = Account(username: username, password: password, address: address, otherAddress: otherAddress, port: port)
				DispatchQueue.main.async {
					accountHolder.account = account
				}
			}

		}
		dismiss()
	}
	func logout() {
		self.address = ""
		self.otherAddress = ""
		self.username = ""
		self.password = ""
		self.port = "4533"
		UserDefaults.standard.removeObject(forKey: "CurrentPlaylist")
		UserDefaults.standard.removeObject(forKey: "UserAccount")
		DispatchQueue.main.async {
			SubsonicClient.shared.account = nil
			accountHolder.account = nil
		}
	}
}
