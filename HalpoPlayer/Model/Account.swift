//
//  Account.swift
//  halpoplayer
//
//  Created by paul on 13/07/2023.
//

import Foundation

struct Account: Codable {
	let username: String
	let password: String
	let address: String
	let otherAddress: String
	let port: String
}
