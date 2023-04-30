//
//  SearchResults.swift
//  NASA
//
//  Created by Ismail Elmaliki on 4/30/23.
//

import Foundation

/// Model representing a **collection** of search results from NASA Search query.
struct SearchResults: Codable {
	let results: [SearchResult]
	
	/// Outer keys to map collection of search results.
	enum CodingKeys: CodingKey {
		case collection
	}
	
	/// Inner key to map collection of search results.
	enum ItemKeys: CodingKey {
		case items
	}
	
	init(from decoder: Decoder) throws {
		let outerContainer = try decoder.container(keyedBy: CodingKeys.self)
		let itemsContainer = try outerContainer.nestedContainer(keyedBy: ItemKeys.self, forKey: .collection)
		
		let items = try itemsContainer.decode([SearchResult].self, forKey: .items)
		
		results = items
	}
	
	func encode(to encoder: Encoder) throws {
		var outerContainer = encoder.container(keyedBy: CodingKeys.self)
		var itemsContainer = outerContainer.nestedContainer(keyedBy: ItemKeys.self, forKey: .collection)
		
		try itemsContainer.encode(results, forKey: .items)
	}
}
