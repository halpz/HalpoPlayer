//
//  AccountListView.swift
//  HalpoPlayer
//
//  Created by paul on 19/10/2023.
//

import SwiftUI

struct AccountListView: View {
	@StateObject var viewModel = AccountListViewModel()
	@ObservedObject var accountManager = AccountHolder.shared
	@State var showLogin = false
	var body: some View {
		if viewModel.accounts.isEmpty {
			Button("Add an account") {
				self.showLogin = true
			}
			.buttonStyle(.borderedProminent)
			.padding()
		}
		List {
			ForEach(viewModel.accounts, id: \.self) { account in
				Button {
					viewModel.setAccount(account)
				} label: {
					if AccountHolder.shared.account == account {
						Text(account.address)
							.foregroundStyle(.green)
					} else {
						Text(account.address)
					}
				}
			}
			.onDelete(perform: viewModel.delete)
		}
		.navigationTitle("Accounts")
		.sheet(isPresented: $showLogin, content: {
			LoginView(address: "", otherAddress: "", username: "", password: "", callback: { account in
				self.viewModel.accounts.append(account)
			})
		})
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					showLogin = true
				} label: {
					Image(systemName: "plus").imageScale(.large)
				}
			}
		}
	}
}

class AccountListViewModel: ObservableObject {
	@Published var accounts: [Account] = {
		if let data = UserDefaults.standard.data(forKey: "StoredAccounts"),
		   let storedAccounts = try? data.decoded() as [Account] {
			return storedAccounts
		} else if let accountData = UserDefaults.standard.data(forKey: "UserAccount"),
				  let account = try? accountData.decoded() as Account {
			if let data = try? [account].encoded() {
				UserDefaults.standard.setValue(data, forKey: "StoredAccounts")
			}
			return [account]
		}
		return []
	}() {
		didSet {
			if let data = try? accounts.encoded() {
				UserDefaults.standard.setValue(data, forKey: "StoredAccounts")
			}
		}
	}
	func setAccount(_ account: Account) {
		UserDefaults.standard.removeObject(forKey: "CurrentPlaylist")
		UserDefaults.standard.removeObject(forKey: "UserAccount")
		DispatchQueue.main.async {
			AccountHolder.shared.account = account
		}
	}
	func delete(at offsets: IndexSet) {
		let account = accounts[offsets.first ?? 0]
		if AccountHolder.shared.account == account {
			self.logout()
		}
		accounts.remove(atOffsets: offsets)
	}
	func logout() {
		Database.shared.reset()
		UserDefaults.standard.removeObject(forKey: "CurrentPlaylist")
		UserDefaults.standard.removeObject(forKey: "UserAccount")
		DispatchQueue.main.async {
			SubsonicClient.shared.account = nil
			SubsonicClient.shared.currentAddress = nil
			AccountHolder.shared.account = nil
		}
	}
}
