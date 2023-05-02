//
//  ImageLoaderTests.swift
//  NASATests
//
//  Created by Ismail Elmaliki on 5/2/23.
//

@testable import NASA
import XCTest

final class ImageLoaderTests: XCTestCase {
	var sut: ImageMockLoader!
	
	override func setUp() {
		super.setUp()
		sut = ImageMockLoader()
	}
	
	override func tearDown() {
		sut = nil
		super.tearDown()
	}
	
	func test_downloadImage_returnsValidImage() async {
		sut.imageTask = .validImage
		
		let searchResult = await SearchResult.generateSearchResult()
		let image = await sut.downloadImage(searchResult)
		
		XCTAssertNotNil(image)
		XCTAssertNotNil(sut.imageSessions[searchResult.id])
		XCTAssertNotNil(sut.imageCache.object(forKey: NSString(string: searchResult.id)))
	}
	
	func test_downloadImage_returnsNilImage() async {
		sut.imageTask = .nilImage
		
		let searchResult = await SearchResult.generateSearchResult()
		let image = await sut.downloadImage(searchResult)
		
		XCTAssertNil(image)
		XCTAssertNotNil(sut.imageSessions[searchResult.id])
		XCTAssertNil(sut.imageCache.object(forKey: NSString(string: searchResult.id)))
	}
	
	func test_downloadImage_thenCancelDownload() async {
		sut.imageTask = .validImage
		
		let searchResult = await SearchResult.generateSearchResult()
		let _ = await sut.downloadImage(searchResult)
		
		sut.cancelImageDownload(searchResult)
		XCTAssertNil(sut.imageSessions[searchResult.id])
	}
}
