//
//  NASAClientAPI.swift
//  NASA
//
//  Created by Ismail Elmaliki on 4/30/23.
//

import Foundation

/// NASA Client API abstraction to perform network requests.
protocol NASAClientAPI {
	/// Single shared instance as per Singleton pattern.
	static var shared: Self { get }
	
	/// Current page index for query search.
	///
	/// Initial value is 0.
	var pageIndex: Int { get }
	
	/// Current query for NASA search.
	var currentQuery: String { get }
	
	/// Performs a network-call to query search NASA API.
	///
	///	Paging logic is handled by this function based on `currentQuery`. 
	/// - Parameters:
	/// 	- query: Free text search that's passed to NASA API
	func search(for query: String) async -> Result<[SearchResult], Error>
}

final class NASAClientProdAPI: NASAClientAPI {
	static let shared = NASAClientProdAPI()
	
	private init() {}
	
	private(set) var pageIndex: Int = 0
	
	private(set) var currentQuery: String = "" {
		willSet {
			if newValue != currentQuery {
				/// Reset page index when query is new
				pageIndex = 0
			}
		}
	}
	
	func search(for query: String) async -> Result<[SearchResult], Error> {
		currentQuery = query
		pageIndex += 1
		
		/// Setup API URL.
		let url = URL(string: "https://images-api.nasa.gov/search?q=\(currentQuery)&media_type=image&page=\(pageIndex)")!
		
		/// Perform network call and handle data mapping.
		do {
			let result = try await URLSession.shared.data(from: url)
			let data = result.0
			
			let decoder = JSONDecoder()
			let searchResults = try decoder.decode(SearchResults.self, from: data)
			return .success(searchResults.results)
		} catch {
			print("Query search error: \(String(describing: error))")
			return .failure(error)
		}
	}
}
