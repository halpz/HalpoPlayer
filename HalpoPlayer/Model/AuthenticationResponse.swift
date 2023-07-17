//
//  AuthenticationResponse.swift
//  halpoplayer
//
//  Created by paul on 13/07/2023.
//

import Foundation

// MARK: - AuthenticationResponse
struct AuthenticationResponse: Codable {
	let subsonicResponse: SubsonicResponse
	
	enum CodingKeys: String, CodingKey {
		case subsonicResponse = "subsonic-response"
	}
	
	// MARK: - SubsonicResponse
	struct SubsonicResponse: Codable {
		let status, serverVersion, type, version: String
	}
}


