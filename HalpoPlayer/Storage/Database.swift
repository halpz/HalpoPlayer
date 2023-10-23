//
//  Database.swift
//  halpoplayer
//
//  Created by paul on 10/07/2023.
//

import Foundation
import UIKit

class Database: ObservableObject {
	static let shared = Database()
	let imageCache = ImageCache.shared
	@Published var albumList: [GetAlbumListResponse.Album]?
//	= {
//		if let documentsUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
//			let albumListFilePath = documentsUrl.appendingPathComponent("albumList")
//			if FileManager.default.fileExists(atPath: albumListFilePath.path()), let albumListData = try? Data(contentsOf: albumListFilePath),
//			   let decodedAlbumList = try? albumListData.decoded() as [GetAlbumListResponse.Album] {
//				return decodedAlbumList
//			}
//		}
//		return nil
//	}() {
//		didSet {
//			if let data = try? albumList?.encoded(), let documentsUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
//				let path = documentsUrl.appendingPathComponent("albumList")
//				guard FileManager.default.fileExists(atPath: path.path()) else {
//					FileManager.default.createFile(atPath: path.path(), contents: data)
//					return
//				}
//				try? data.write(to: path)
//			}
//		}
//	}
	@Published var artistList: [GetArtistsResponse.Artist]?
	@Published var playlists: GetPlaylistsResponse?
	@Published var searchResults: Search2Response?
	@Published var searchScope: SearchScope
	@Published var searchText: String
	@Published var libraryViewType: LibraryViewType = .albums
	@Published var libraryLayout: LibraryLayout = {
		if let grid = UserDefaults.standard.object(forKey: "Grid") as? Bool {
			return grid ? .grid : .list
		} else {
			let grid = UIDevice.current.userInterfaceIdiom == .pad
			UserDefaults.standard.setValue(grid, forKey: "Grid")
			return grid ? .grid : .list
		}
	}() {
		didSet {
			let isGrid = libraryLayout == .grid
			UserDefaults.standard.setValue(isGrid, forKey: "Grid")
		}
	}
	@Published var libraryAlbumSortType: AlbumSortType = {
		if let data = UserDefaults.standard.data(forKey: "SortOrder"),
		   let sort = try? data.decoded() as AlbumSortType {
			return sort
		} else {
			let sort = AlbumSortType.newest
			if let data = try? sort.encoded() {
				UserDefaults.standard.setValue(data, forKey: "SortOrder")
			}
			return sort
		}
	}() {
		didSet {
			if let data = try? libraryAlbumSortType.encoded() {
				UserDefaults.standard.setValue(data, forKey: "SortOrder")
			}
		}
	}
	var albumPage = 0
	@Published var musicCache: [String: CachedSong] {
		didSet {
			guard let data = try? musicCache.encoded(), let documentsUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
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
			if FileManager.default.fileExists(atPath: musicCachePath.path()), let musicCacheData = try? Data(contentsOf: musicCachePath),
			   let decodedMusicCache = try? musicCacheData.decoded() as [String: CachedSong] {
				self.musicCache = decodedMusicCache
			} else {
				self.musicCache = [:]
			}
		} else {
			self.musicCache = [:]
		}
	}
	func reset() {
		albumList = nil
		artistList = nil
		playlists = nil
		searchResults = nil
		searchScope = .song
		searchText = ""
		libraryViewType = .albums
		self.albumPage = 0
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
					callback()
				} catch {
					print("Song caching error: \(error)")
				}
			}
		}
	}
	func deleteSong(song: Song, callback: (() -> Void)? = nil) {
		if let cached = self.musicCache[song.id] {
			deleteSong(cached: cached, callback: callback)
		}
	}
	func deleteSong(cached: CachedSong, callback: (() -> Void)? = nil) {
		do {
			if let documentsUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
				let fileUrl = documentsUrl.appendingPathComponent(cached.path)
				try FileManager.default.removeItem(atPath: fileUrl.path())
				DispatchQueue.main.async {
					self.musicCache.removeValue(forKey: cached.song.id)
				}
				callback?()
			}
		} catch {
			print("Could not delete file: \(error)")
			DispatchQueue.main.async {
				self.musicCache.removeValue(forKey: cached.song.id)
			}
			callback?()
		}
	}
}
