//
//  ListSearchViewModel.swift
//  NASA
//
//  Created by Ismail Elmaliki on 5/2/23.
//

import UIKit

protocol ListSearchViewModel {
	/// Current query text user submits via search bar.
	var currentSearchText: String { get }
	
	/// List of search results based on query text.
	var searchResults: [SearchResult] { get }
	
	/// NASA Client API.
	var nasaAPI: NASAClientAPI { get }
	
	/// Image loader/cache for search results.
	var imageLoader: ImageLoader { get }
	
	/// Generates displayable text for empty search results
	var noResultsText: String { get }
	
	/// Sets `currentSearchText` when user performs query in search bar.
	func setSearch(with query: String)
	
	/// Performs a call and returns results from `NASAClientAPI`.
	func performSearch() async -> ListLoadAction
	
	/// Clears search results and its associated image cache.
	func clearResults()
}

enum ListLoadAction {
	case none
	case reloadAll
	case reloadRows
}

final class ListSearchVMImplementer: ListSearchViewModel {
	private(set) var currentSearchText: String = ""
	private(set) var searchResults: [SearchResult] = []
	
	let nasaAPI: NASAClientAPI
	let imageLoader: ImageLoader
	
	init(
		imageLoader: ImageLoader = ImageProdLoader.shared,
		nasaAPI: NASAClientAPI = NASAClientProdAPI.shared
	) {
		self.imageLoader = imageLoader
		self.nasaAPI = nasaAPI
	}
	
	var noResultsText: String {
		return NSLocalizedString(
			"No results found here for \"\(currentSearchText)\" 🔍",
			comment: "no-results"
		)
	}
	
	func setSearch(with query: String) {
		currentSearchText = query
	}
	
	func performSearch() async -> ListLoadAction {
		let result = await nasaAPI.search(for: currentSearchText)
		guard let newSearchResults = try? result.get() else {
			return .none
		}
		
		if nasaAPI.pageIndex == 1 {
			searchResults = newSearchResults
			return .reloadAll
		} else {
			searchResults.append(contentsOf: newSearchResults)
			return .reloadRows
		}
	}
	
	func clearResults() {
		currentSearchText.removeAll()
		searchResults = []
		imageLoader.imageCache.removeAllObjects()
	}
}
