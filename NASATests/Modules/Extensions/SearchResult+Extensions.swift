//
//  SearchResult+Extensions.swift
//  NASATests
//
//  Created by Ismail Elmaliki on 5/2/23.
//

@testable import NASA
import Foundation

extension SearchResult {
	
	/// Generate a new instance of `SearchResult` for unit testing purposes.
	static func generateSearchResult() async -> Self {
		let nasaAPI = NASAClientMockAPI()
		let result = await nasaAPI.search(for: .mars)
		let searchResults = try! result.get()
		let searchResult = searchResults.first!
		
		return searchResult
	}
}
