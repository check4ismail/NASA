//
//  ImageMockLoader.swift
//  NASATests
//
//  Created by Ismail Elmaliki on 5/2/23.
//

@testable import NASA
import UIKit

enum ImageTask {
	case validImage
	case nilImage
	
	var image: UIImage? {
		switch self {
		case .validImage:
			return UIImage(systemName: "folder")
		case .nilImage:
			return nil
		}
	}
}

final class ImageMockLoader: ImageLoader {
	private(set) var imageCache: NSCache<NSString, UIImage> = NSCache()
	private(set) var imageSessions: [String : URLSessionDataTask] = [:]
	
	var imageTask: ImageTask = .validImage
	
	func downloadImage(_ searchResult: NASA.SearchResult) async -> UIImage? {
		let task = URLSessionDataTask()
		
		if imageTask == .validImage {
			imageCache.setObject(imageTask.image!, forKey: NSString(string: searchResult.id))
		}
		
		imageSessions[searchResult.id] = task
		
		return imageTask.image
	}
	
	func cancelImageDownload(_ searchResult: NASA.SearchResult) {
		imageSessions[searchResult.id] = nil
	}
}
