//
//  Error.swift
//  halpoplayer
//
//  Created by paul on 13/07/2023.
//

import Foundation

enum HalpoError: LocalizedError {
	case badResponse(code: Int)
	case imageDecode
	case documentsDirectoryNotFound
	case noAccount
	case noURL
	case offline
}
