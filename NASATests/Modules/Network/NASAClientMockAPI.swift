//
//  NASAClientMockAPI.swift
//  NASATests
//
//  Created by Ismail Elmaliki on 5/2/23.
//

@testable import NASA
import Foundation

enum DataRequest: String {
	case mars
	case jupiter
	case empty = "aaaaaa"
	case error
	
	func generateURL(_ index: Int) -> URL {
		let bundle = Bundle(for: NASAClientMockAPI.self)
		switch self {
		case .mars, .jupiter:
			return bundle.url(forResource: "\(rawValue)-page-\(index)", withExtension: "json")!
		case .empty:
			return bundle.url(forResource: "empty-results", withExtension: "json")!
		case .error:
			return bundle.url(forResource: rawValue, withExtension: "json")!
		}
	}
}

final class NASAClientMockAPI: NASAClientAPI {
	static let shared = NASAClientMockAPI()
	
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
	
	func search(for request: DataRequest) async -> Result<[SearchResult], Error> {
		return await search(for: request.rawValue)
	}
	
	func search(for query: String) async -> Result<[SearchResult], Error> {
		currentQuery = query
		pageIndex += 1
		
		/// Perform network call and handle data mapping.
		do {
			let dataRequest = DataRequest(rawValue: query)!
			let fileURL = dataRequest.generateURL(pageIndex)
			let data = try Data(contentsOf: fileURL)
			
			let decoder = JSONDecoder()
			let searchResults = try decoder.decode(SearchResults.self, from: data)
			return .success(searchResults.results)
		} catch {
			print("Query search error: \(String(describing: error))")
			return .failure(error)
		}
	}
}
