//
//  NASAClientMockAPI.swift
//  NASATests
//
//  Created by Ismail Elmaliki on 5/2/23.
//

@testable import NASA
import Foundation

/// Data request for mocking NASA query API.
enum DataRequest: String {
	/// Request to query "mars"
	case mars
	
	/// Request to query "jupiter"
	case jupiter
	
	/// Query for "aaaaaa" to generate empty results.
	case empty = "aaaaaa"
	
	/// Request that forces an error.
	case error
	
	/// Returns URL file path of mock JSON response.
	///
	/// Depending on current `DataRequest`, appropriate JSON URL file is returned.
	func generateURL() -> URL {
		let bundle = Bundle(for: NASAClientMockAPI.self)
		switch self {
		case .mars, .jupiter:
			return bundle.url(forResource: rawValue + "-page", withExtension: "json")!
		case .empty:
			return bundle.url(forResource: "empty-results", withExtension: "json")!
		case .error:
			return bundle.url(forResource: rawValue, withExtension: "json")!
		}
	}
}

final class NASAClientMockAPI: NASAClientAPI {
	static let shared = NASAClientMockAPI()
	
	private(set) var pageIndex: Int = 0
	
	private(set) var currentQuery: String = "" {
		willSet {
			if newValue != currentQuery {
				/// Reset page index when query is new
				pageIndex = 0
			}
		}
	}
	
	func search(for request: DataRequest) async -> Result<[SearchResult], Error> {
		return await search(for: request.rawValue)
	}
	
	func search(for query: String) async -> Result<[SearchResult], Error> {
		currentQuery = query
		pageIndex += 1
		
		/// Perform network call and handle data mapping.
		do {
			/// Fetch data request based on `query`
			let dataRequest = DataRequest(rawValue: query)!
			
			/// Fetch JSON file based on `dataRequest`.
			let fileURL = dataRequest.generateURL()
			
			/// Fetch data of JSON file.
			let data = try Data(contentsOf: fileURL)
			
			/// Attempt to perform decoding of data.
			let decoder = JSONDecoder()
			let searchResults = try decoder.decode(SearchResults.self, from: data)
			return .success(searchResults.results)
		} catch {
			print("Query search error: \(String(describing: error))")
			return .failure(error)
		}
	}
}
