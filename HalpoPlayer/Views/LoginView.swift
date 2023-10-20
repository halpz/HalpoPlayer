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
	@State var loading = false
	var callback: ((Account) -> Void)?
	var body: some View {
		ZStack {
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
			if loading {
				ProgressView()
			}
		}
	}
	func submit() {
		print("done")
		self.loading = true
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
			
			Task {
				do {
					let success = try await SubsonicClient.shared.testAddressesForPermission(ad1: self.combineAddressWithPort(address: address, port: port), ad2: self.combineAddressWithPort(address: otherAddress, port: port))
					if success {
						let account = Account(username: username, password: password, address: address, otherAddress: otherAddress, port: port)
						DispatchQueue.main.async {
							accountHolder.account = account
							self.callback?(account)
							self.dismiss()
						}
					} else {
						SubsonicClient.shared.showCode(code: 0, message: "Could not ping either address\n\(address)\n\(otherAddress)")
					}
					self.loading = false
				} catch {
					print(error)
					self.loading = false
				}
			}
		}
	}
	func combineAddressWithPort(address: String, port: String) -> String {
		var trimmed = address.replacingOccurrences(of: "http://", with: "")
		trimmed = trimmed.replacingOccurrences(of: "https://", with: "")
		if trimmed.contains(":") {
			return address
		} else {
			return "\(address):\(port)"
		}
	}
}
