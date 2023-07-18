//
//  BasicResponse.swift
//  HalpoPlayer
//
//  Created by paul on 18/07/2023.
//

import Foundation

// MARK: - BasicResponse
struct BasicResponse: Codable {
	let subsonicResponse: SubsonicResponse

	enum CodingKeys: String, CodingKey {
		case subsonicResponse = "subsonic-response"
	}

	// MARK: - SubsonicResponse
	struct SubsonicResponse: Codable {
		let status, serverVersion, type, version: String
	}
}


