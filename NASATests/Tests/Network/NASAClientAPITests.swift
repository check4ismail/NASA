//
//  NASAClientAPITests.swift
//  NASATests
//
//  Created by Ismail Elmaliki on 5/2/23.
//

import XCTest

final class NASAClientAPITests: XCTestCase {
	var sut: NASAClientMockAPI!
	
	override func setUp() {
		super.setUp()
		sut = NASAClientMockAPI()
	}
	
	override func tearDown() {
		sut = nil
		super.tearDown()
	}
	
	func test_search_withQueryMars() async {
		let dataRequest = DataRequest.mars
		let result = await sut.search(for: dataRequest)
		
		XCTAssertNotNil(try? result.get())
		XCTAssertTrue(sut.pageIndex == 1)
		XCTAssertTrue(sut.currentQuery == dataRequest.rawValue)
	}
	
	func test_search_withQueryJupiter() async {
		let dataRequest = DataRequest.jupiter
		let result = await sut.search(for: dataRequest)
		
		XCTAssertNotNil(try? result.get())
		XCTAssertTrue(sut.pageIndex == 1)
		XCTAssertTrue(sut.currentQuery == dataRequest.rawValue)
	}
	
	func test_search_returnsEmptyResults() async {
		let dataRequest = DataRequest.empty
		let result = await sut.search(for: dataRequest)
		
		XCTAssertNotNil(try? result.get())
		
		let searchResults = try! result.get()
		
		XCTAssertTrue(searchResults.isEmpty)
		XCTAssertTrue(sut.pageIndex == 1)
		XCTAssertTrue(sut.currentQuery == dataRequest.rawValue)
	}
	
	func test_search_returnsError() async {
		let dataRequest = DataRequest.error
		let result = await sut.search(for: dataRequest)
		
		XCTAssertNil(try? result.get())
	}
	
	func test_searchMars_withPaging() async {
		let dataRequest = DataRequest.mars
		let _ = await sut.search(for: dataRequest)
		
		/// Second request for second page
		let result = await sut.search(for: dataRequest)
		
		XCTAssertNotNil(try? result.get())
		XCTAssertTrue(sut.pageIndex == 2)
		XCTAssertTrue(sut.currentQuery == dataRequest.rawValue)
	}
	
	func test_searchJupiter_withPaging() async {
		let dataRequest = DataRequest.jupiter
		let _ = await sut.search(for: dataRequest)
		
		/// Second request for second page
		let result = await sut.search(for: dataRequest)
		
		XCTAssertNotNil(try? result.get())
		XCTAssertTrue(sut.pageIndex == 2)
		XCTAssertTrue(sut.currentQuery == dataRequest.rawValue)
	}
	
	func test_searchMars_thenJupiter() async {
		let _ = await sut.search(for: .mars)
		
		let secondRequest: DataRequest = .jupiter
		let result = await sut.search(for: secondRequest)
		
		XCTAssertNotNil(try? result.get())
		XCTAssertTrue(sut.pageIndex == 1)
		XCTAssertTrue(sut.currentQuery == secondRequest.rawValue)
	}
}
