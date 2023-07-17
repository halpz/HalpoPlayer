//
//  ImageCache.swift
//  halpoplayer
//
//  Created by paul on 13/07/2023.
//

import UIKit

class ImageCache {
	static let shared = ImageCache()
	let lock = NSLock()
	private var cache: [String: String] {
		didSet {
			guard let data = try? JSONEncoder().encode(cache), let documentsUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
				return
			}
			let path = documentsUrl.appendingPathComponent("imageCache")
			guard FileManager.default.fileExists(atPath: path.path()) else {
				FileManager.default.createFile(atPath: path.path(), contents: data)
				return
			}
			try? data.write(to: path)
		}
	}
	init() {
		if let documentsUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
			let imagesDirectoryPath = documentsUrl.appendingPathComponent("images", conformingTo: .directory)
			var isDirectory: ObjCBool = true
			if !FileManager.default.fileExists(atPath: imagesDirectoryPath.path(), isDirectory: &isDirectory) {
				try? FileManager.default.createDirectory(at: imagesDirectoryPath, withIntermediateDirectories: false)
			}
			let imageCachePath = documentsUrl.appendingPathComponent("imageCache")
			let decoder = JSONDecoder()
			if FileManager.default.fileExists(atPath: imageCachePath.path()), let imageCacheData = try? Data(contentsOf: imageCachePath),
			   let decodedImageCache = try? decoder.decode([String: String].self, from: imageCacheData) {
				self.cache = decodedImageCache
			} else {
				self.cache = [String: String]()
			}
		} else {
			self.cache = [String: String]()
		}
	}
	func image(albumId: String) -> UIImage? {
		if let path = cache[albumId] {
			if let documentsUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
				let imagePath = documentsUrl.appendingPathComponent(path)
				if FileManager.default.fileExists(atPath: imagePath.path()) {
					if let imageData = try? Data(contentsOf: imagePath) {
						return UIImage(data: imageData)
					}
				}
			}
		}
		return nil
	}
	func cacheImage(albumId: String, image: UIImage) {
		if let documentsUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
			let pathComponent = "images/\(UUID()).jpg"
			let imagePath = documentsUrl.appendingPathComponent(pathComponent)
			let data = image.jpegData(compressionQuality: 0.6)
			FileManager.default.createFile(atPath: imagePath.path(), contents: data)
			lock.lock()
			self.cache[albumId] = pathComponent
			lock.unlock()
		}
	}
}
