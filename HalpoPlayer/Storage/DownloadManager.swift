//
//  DownloadManager.swift
//  HalpoPlayer
//
//  Created by paul on 18/07/2023.
//

import Foundation

class DownloadManager: ObservableObject {
	static let shared = DownloadManager()
	@Published var downloadingSongs: [Song]
	init() {
		downloadingSongs = [Song]()
	}
}
