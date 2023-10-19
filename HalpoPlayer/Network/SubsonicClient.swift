//
//  SubsonicClient.swift
//  halpoplayer
//
//  Created by paul on 07/07/2023.
//

import UIKit

class SubsonicClient {
	var currentAddress: String?
	var account: Account?
	let session = URLSession(configuration: .default)
	static let shared = SubsonicClient()
	var userString: String {
		guard let account = account else {
			return ""
		}
		return "&f=json&u=\(account.username)&p=\(account.password)&v=1.16.1&c=halpoplayer"
	}
	func request<T: Decodable>(_ api: SubsonicAPI) async throws -> T {
		
		
		if self.currentAddress == nil {
			do {
				_ = try await self.authenticate()
			} catch {
				self.showCode(code: 0, message: "Authentication error: \(error)")
			}
		}
		
		guard let currentAddress = currentAddress else {
			throw HalpoError.noAccount
		}
		
		guard let url = URL(string: "\(currentAddress)/rest/\(api.pathComponent)\(userString)") else {
			throw HalpoError.noURL
		}
		var urlRequest = URLRequest(url: url)
		urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
		urlRequest.httpMethod = api.method
		let (data, response) = try await self.session.data(for: urlRequest)
		if let code = (response as? HTTPURLResponse)?.statusCode, code != 200 {
			self.showCode(code: code, message: "URLRequest error")
			printJSONData(data)
			throw HalpoError.badResponse(code: code)
		}
//		switch api {
//		case .createPlaylist:
//			printJSONData(data)
//		default:
//			break
//		}
		do {
			return try JSONDecoder().decode(T.self, from: data)
		} catch {
			self.showCode(code: 0, message: "JSON Decoder error: \(error.localizedDescription)")
			print(error)
			throw HalpoError.imageDecode
		}
	}
	func showCode(code: Int, message: String? = nil) {
		return
		let alert = UIAlertController(title: "Error", message: "error code: \(code) \(message ?? "")", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		DispatchQueue.main.async {
			UIApplication.shared.rootView?.present(alert, animated: true)
		}
	}
	func dataRequest(_ api: SubsonicAPI) async throws -> (Data, URLResponse) {
		guard let currentAddress = currentAddress else {
			throw HalpoError.noAccount
		}
		guard let url = URL(string: "\(currentAddress)/rest/\(api.pathComponent)\(userString)") else {
			throw HalpoError.noURL
		}
		var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = api.method
		let (data, response) = try await self.session.data(for: urlRequest)
		if let code = (response as? HTTPURLResponse)?.statusCode, code != 200 {
			printJSONData(data)
			throw HalpoError.badResponse(code: code)
		}
		return (data, response)
	}
	func setAddress(address: String) async throws {
		guard account != nil else {
			throw HalpoError.noAccount
		}
		var urlRequest = URLRequest(url: URL(string: address)!)
		urlRequest.httpMethod = "HEAD"
		urlRequest.timeoutInterval = 5
		_ = try await session.data(for: urlRequest)
		currentAddress = address
	}
	func authenticate() async throws -> Bool {
		guard let account = self.account else {
			return false
		}
		do {
			try await setAddress(address: "\(account.address):\(account.port)")
			AccountHolder.shared.offline = false
		} catch {
			do {
				try await setAddress(address: "\(account.otherAddress):\(account.port)")
				AccountHolder.shared.offline = false
			} catch {
				AccountHolder.shared.offline = true
				throw HalpoError.offline
			}
		}
		guard currentAddress != nil else {
			AccountHolder.shared.offline = true
			throw HalpoError.offline
		}
		let response = try await request(.authenticate) as AuthenticationResponse
		return response.subsonicResponse.status == "ok"
	}
	func downloadSong(song: Song) async throws -> (Data, URLResponse, CachedSong) {
		let (data, response) = try await dataRequest(.stream(id: song.id, mp3: false))
		let album = try await getAlbum(id: song.albumId)
		let coverArtUrl = coverArtURL(albumId: song.albumId)
		let cachedSong = CachedSong(song: song, album: album.subsonicResponse.album, imageUrl: coverArtUrl, path: "")
		return (data, response, cachedSong)
	}
	func stream(id: String, mp3: Bool = false) throws -> URL {
		guard let currentAddress = currentAddress else { throw HalpoError.noAccount }
		let api = SubsonicAPI.stream(id: id, mp3: mp3)
		let url = URL(string: "\(currentAddress)/rest/\(api.pathComponent)\(userString)")!
		return url
	}
	func coverArt(albumId: String) async throws -> UIImage {
		if let image = Database.shared.imageCache.image(albumId: albumId) {
			return image
		}
		let (data, _) = try await dataRequest(.coverArt(albumId: albumId))
		if let image = UIImage(data: data) {
			Database.shared.imageCache.cacheImage(albumId: albumId, image: image)
			return image
		} else {
			throw HalpoError.imageDecode
		}
	}
	func downloadAvatar(artistId: String, artistImageUrl: String) async throws -> UIImage {
		if let image = Database.shared.imageCache.image(albumId: artistId) {
			return image
		}
		let url = URL(string: artistImageUrl)!
		let urlRequest = URLRequest(url: url)
		let (data, _) = try await session.data(for: urlRequest)
		if let image = UIImage(data: data) {
			Database.shared.imageCache.cacheImage(albumId: artistId, image: image)
			return image
		} else {
			throw HalpoError.imageDecode
		}
	}
	func getIndexes() async throws -> GetIndexesResponse {
		return try await request(.getIndexes) as GetIndexesResponse
	}
	func getAlbumList(page: Int, sort: AlbumSortType = .newest) async throws -> GetAlbumListResponse {
		return try await request(.getAlbumList(page: page, sort: sort)) as GetAlbumListResponse
	}
	func getAlbum(id: String) async throws -> GetAlbumResponse {
		return try await request(.getAlbum(id: id)) as GetAlbumResponse
	}
	func getRandomSongs(albumId: String? = nil) async throws -> GetRandomSongsResponse {
		return try await request(.randomSongs(albumId: albumId)) as GetRandomSongsResponse
	}
	func coverArtURL(albumId: String) -> URL {
		return URL(string: "\(currentAddress!)/rest/getCoverArt?\(userString)&id=\(albumId)")!
	}
	func search2(term: String) async throws -> Search2Response {
		return try await request(.search(term: term)) as Search2Response
	}
	func getSimilarSongs(id: String) async throws -> String {
		return try await request(.getSimilarSongs(id: id)) as String
	}
	func getPlaylists() async throws -> GetPlaylistsResponse {
		return try await request(.getPlaylists) as GetPlaylistsResponse
	}
	func getPlaylist(id: String) async throws -> GetPlaylistResponse {
		return try await request(.getPlaylist(id: id)) as GetPlaylistResponse
	}
	func updatePlaylist(id: String, songs: [Song]) async throws -> BasicResponse {
		return try await request(.updatePlaylist(id: id, songs: songs)) as BasicResponse
	}
	func addSongToPlaylist(playlistId: String, songIds: [String]) async throws -> BasicResponse{
		return try await request(.addSongsToPlaylist(playlistId: playlistId, songIds: songIds)) as BasicResponse
	}
	func getArtists() async throws -> GetArtistsResponse {
		return try await request(.getArtists) as GetArtistsResponse
	}
	func getArtist(id: String) async throws -> GetArtistResponse {
		return try await request(.getArtist(id: id)) as GetArtistResponse
	}
	func getArtistInfo(id: String) async throws -> GetArtistInfoResponse {
		return try await request(.getArtistInfo(id: id)) as GetArtistInfoResponse
	}
	func createPlaylist(name: String) async throws -> CreatePlaylistResponse {
		return try await request(.createPlaylist(name: name)) as CreatePlaylistResponse
	}
	func printJSONData(_ data: Data) {
		if let json = try? JSONSerialization.jsonObject(with: data, options: []),
		   let data = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted]),
		   let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
			print(prettyPrintedString)
		}
	}
	func testAddressesForPermission(ad1: String, ad2: String) async throws -> Bool {
		if ad1 != "http://" {
			let url = URL(string: ad1)!
			var urlRequest = URLRequest(url: url)
			urlRequest.httpMethod = "HEAD"
			do {
				_ = try await session.data(for: urlRequest)
				return true
			} catch {
				print(error)
			}
		}
		if ad2 != "http://" {
			let url = URL(string: ad2)!
			var urlRequest = URLRequest(url: url)
			urlRequest.httpMethod = "HEAD"
			do {
				_ = try await session.data(for: urlRequest)
				return true
			} catch {
				print(error)
				throw error
			}
		}
		
		throw HalpoError.offline
	}
}
