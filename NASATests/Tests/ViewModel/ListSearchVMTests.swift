//
//  ListSearchVMTests.swift
//  NASATests
//
//  Created by Ismail Elmaliki on 5/2/23.
//

@testable import NASA
import XCTest

final class ListSearchVMTests: XCTestCase {
	var sut: ListSearchVMImplementer!
	
	override func setUp() {
		super.setUp()
		sut = ListSearchVMImplementer(
			imageLoader: ImageMockLoader(),
			nasaAPI: NASAClientMockAPI()
		)
	}
	
	override func tearDown() {
		sut = nil
		super.tearDown()
	}
	
	func test_performSearchWithError_loadActionIsNone() async {
		let request = DataRequest.error
		sut.setSearch(with: request.rawValue)
		
		let expectedLoadAction: ListLoadAction = .none
		let loadAction = await sut.performSearch()
		
		XCTAssertEqual(sut.currentSearchText, request.rawValue)
		XCTAssertEqual(loadAction, expectedLoadAction)
	}
	
	func test_performMarsSearch_loadActionIsReloadAll() async {
		let request = DataRequest.mars
		sut.setSearch(with: request.rawValue)
		
		let expectedLoadAction: ListLoadAction = .reloadAll
		let loadAction = await sut.performSearch()
		
		XCTAssertEqual(sut.currentSearchText, request.rawValue)
		XCTAssertEqual(loadAction, expectedLoadAction)
	}
	
	func test_performMarsSearchTwice_loadActionIsReloadRows() async {
		let request = DataRequest.mars
		sut.setSearch(with: request.rawValue)
		
		let expectedLoadAction: ListLoadAction = .reloadRows
		
		/// Perform search twice with same query (paging).
		let _ = await sut.performSearch()
		let loadAction = await sut.performSearch()
		
		XCTAssertEqual(sut.currentSearchText, request.rawValue)
		XCTAssertEqual(loadAction, expectedLoadAction)
	}
	
	func test_performSearch_thenClearResults() async {
		let request = DataRequest.mars
		sut.setSearch(with: request.rawValue)
		
		
		/// Perform search twice with same query (paging).
		let _ = await sut.performSearch()
		let searchResult = sut.searchResults.first!
		
		/// Fetch image to populate cache
		let _ = await sut.imageLoader.downloadImage(searchResult)
		
		/// Clear results
		sut.clearResults()
		
		XCTAssertTrue(sut.currentSearchText.isEmpty)
		XCTAssertTrue(sut.searchResults.isEmpty)
		XCTAssertNil(sut.imageLoader.imageCache[searchResult.id])
	}
	
	func test_setSearch_thenGetNoResultsText() {
		let searchText = "Test"
		sut.setSearch(with: searchText)
		
		let expectedResultsText = "No results found here for \"\(searchText)\" 🔍"
		XCTAssertEqual(sut.noResultsText, expectedResultsText)
	}
}
