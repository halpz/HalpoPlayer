//
//  LoginView.swift
//  halpoplayer
//
//  Created by paul on 10/07/2023.
//

import SwiftUI

struct LoginView: View {
	@Environment(\.dismiss) var dismiss
	@EnvironmentObject var accountHolder: AccountHolder
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
	}
	func submit() {
		print("done")
		Task {
			if !address.contains("http://") {
				address = "http://" + address
			}
			if !otherAddress.contains("http://") {
				otherAddress = "http://" + otherAddress
			}
			let account = Account(username: username, password: password, address: address, otherAddress: otherAddress, port: port)
			accountHolder.account = account
			if !(try await SubsonicClient.shared.authenticate()) {
				Database.shared.albums = []
			}
		}
		dismiss()
	}
}
