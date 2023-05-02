//
//  SearchResult.swift
//  NASA
//
//  Created by Ismail Elmaliki on 4/30/23.
//

import Foundation

/// Model representing individual search result of performing a NASA Search query.
struct SearchResult: Codable {
	let id: String
	let description: String
	let title: String
	let photographer: String?
	let location: String?
	let imageURL: String
	
	/// Outer keys to map NASA API response data to `SearchResult`.
	enum CodingKeys: CodingKey {
		case data
		case links
	}
	
	/// Sub-model of `SearchResult` containing most elements.
	private struct Data: Codable {
		let nasa_id: String
		let description: String
		let title: String
		let photographer: String?
		let location: String?
	}
	
	/// Sub-model of `SearchResult` that contains the `imageURL` link.
	private struct Link: Codable {
		let href: String
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let datas = try container.decode([Data].self, forKey: .data)
		let links = try container.decode([Link].self, forKey: .links)
		
		let data = datas.first!
		let link = links.first!
		
		description = data.description
		title = data.title
		photographer = data.photographer
		location = data.location
		id = data.nasa_id
		imageURL = link.href
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		let data = Data(nasa_id: id, description: description, title: title, photographer: photographer, location: location)
		let link = Link(href: imageURL)
		
		try container.encode([data], forKey: .data)
		try container.encode([link], forKey: .links)
	}
}
