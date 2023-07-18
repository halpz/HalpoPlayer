//
//  Database.swift
//  halpoplayer
//
//  Created by paul on 10/07/2023.
//

import Foundation

class Database: ObservableObject {
	static let shared = Database()
	let imageCache = ImageCache.shared
	@Published var albumList: [GetAlbumListResponse.Album]?
	@Published var playlists: GetPlaylistsResponse?
	@Published var searchResults: Search2Response?
	@Published var searchScope: SearchScope
	@Published var searchText: String
	@Published var musicCache: [String: CachedSong] {
		didSet {
			guard let data = try? JSONEncoder().encode(musicCache), let documentsUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
				return
			}
			let path = documentsUrl.appendingPathComponent("musicCache")
			guard FileManager.default.fileExists(atPath: path.path()) else {
				FileManager.default.createFile(atPath: path.path(), contents: data)
				return
			}
			try? data.write(to: path)
		}
	}
	init() {
		searchText = ""
		searchScope = .song
		if let documentsUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
			let musicCachePath = documentsUrl.appendingPathComponent("musicCache")
			let decoder = JSONDecoder()
			if FileManager.default.fileExists(atPath: musicCachePath.path()), let musicCacheData = try? Data(contentsOf: musicCachePath),
			   let decodedMusicCache = try? decoder.decode([String: CachedSong].self, from: musicCacheData) {
				self.musicCache = decodedMusicCache
			} else {
				self.musicCache = [String: CachedSong]()
			}
		} else {
			self.musicCache = [String: CachedSong]()
		}
	}
	func downloadSong(song: Song) async throws -> CachedSong {
		let (data, response, cached) = try await SubsonicClient.shared.downloadSong(song: song)
		let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
		let savedMusicPath = documentsURL.appendingPathComponent("saved", conformingTo: .directory)
		var isDirectory: ObjCBool = true
		if !FileManager.default.fileExists(atPath: savedMusicPath.path(), isDirectory: &isDirectory) {
			try FileManager.default.createDirectory(at: savedMusicPath, withIntermediateDirectories: false)
		}
		let pathComponent = "saved/\(UUID())\(response.suggestedFilename?.replacingOccurrences(of: "stream", with: "") ?? ".mp3")"
		print(pathComponent)
		let filePath = documentsURL.appendingPathComponent(pathComponent)
		FileManager.default.createFile(atPath: filePath.path(), contents: nil)
		try data.write(to: filePath)
		let newCachedSong = CachedSong(song: cached.song, album: cached.album, imageUrl: cached.imageUrl, path: pathComponent)
		return newCachedSong
	}
	func retrieveSong(song: Song) -> URL? {
		guard let pathComponent = musicCache[song.id]?.path else {
			return nil
		}
		if let documentsUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
			let fileUrl = documentsUrl.appendingPathComponent(pathComponent)
			return fileUrl
		}
		return nil
	}
	func cacheSong(song: Song, callback: @escaping () -> Void) {
		if song.suffix == "opus" {
			callback()
			return
		}
		if self.musicCache[song.id] == nil {
			Task {
				do {
					let toCache = try await self.downloadSong(song: song)
					DispatchQueue.main.async {
						self.musicCache[song.id] = toCache
					}
					print("Song cached: \(song.title)")
					callback()
				} catch {
					print("Song caching error: \(error)")
				}
			}
		}
	}
	func deleteSong(song: Song) {
		if let cached = self.musicCache[song.id] {
			deleteSong(cached: cached)
		}
	}
	func deleteSong(cached: CachedSong) {
		do {
			if let documentsUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
				let fileUrl = documentsUrl.appendingPathComponent(cached.path)
				try FileManager.default.removeItem(atPath: fileUrl.path())
				DispatchQueue.main.async {
					self.musicCache.removeValue(forKey: cached.song.id)
				}
			}
		} catch {
			print("Could not delete file: \(error)")
			DispatchQueue.main.async {
				self.musicCache.removeValue(forKey: cached.song.id)
			}
		}
	}
}
