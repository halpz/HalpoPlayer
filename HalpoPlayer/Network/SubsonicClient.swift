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
	func setAddress(address: String) async throws {
		guard account != nil else {
			throw HalpoError.noAccount
		}
		var urlRequest = URLRequest(url: URL(string: address)!)
		urlRequest.httpMethod = "HEAD"
		urlRequest.timeoutInterval = 5
		do {
			_ = try await session.data(for: urlRequest)
			currentAddress = address
		}
	}
	func request<T: Decodable>(_ api: SubsonicAPI) async throws -> T {
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
		return try JSONDecoder().decode(T.self, from: data)
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
	func authenticate() async throws -> Bool {
		guard let account = self.account else {
			return false
		}
		do {
			try await setAddress(address: "\(account.address):\(account.port)")
		} catch {
			do {
				try await setAddress(address: "\(account.otherAddress):\(account.port)")
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
	func stream(id: String, mp3: Bool = false) -> URL {
		let api = SubsonicAPI.stream(id: id, mp3: mp3)
		let url = URL(string: "\(currentAddress!)/rest/\(api.pathComponent)\(userString)")!
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
	func getIndexes() async throws -> GetIndexesResponse {
		return try await request(.getIndexes) as GetIndexesResponse
	}
	func getAlbumList() async throws -> GetAlbumListResponse {
		return try await request(.getAlbumList) as GetAlbumListResponse
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
	func printJSONData(_ data: Data) {
		if let json = try? JSONSerialization.jsonObject(with: data, options: []),
		   let data = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted]),
		   let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
			print(prettyPrintedString)
		}
	}
}
