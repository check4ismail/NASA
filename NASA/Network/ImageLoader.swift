//
//  ImageLoader.swift
//  NASA
//
//  Created by Ismail Elmaliki on 4/30/23.
//

import Foundation
import UIKit

/// Abstract Image Loader.
///
/// Downloads and caches search result images.
protocol ImageLoader {
	/// In-memory image cache.
	///
	/// Using a key-store pair approach with NSCache, it uses the search result's `id` to cache its `UIImage`.
	var imageCache: NSCache<NSString, UIImage> { get }
	
	/// Dictionary to keep track of all image sessions being processed.
	///
	/// Sessions are mapped uniquely to a search result's `id`.
	var imageSessions: [String: URLSessionDataTask] { get }
	
	/// Download image using SearchResult`id` then add to image cache.
	///
	/// If image is in cache, then it returns image to prevent redundant network call.
	func downloadImage(_ searchResult: SearchResult) async -> UIImage?
	
	/// Cancels existing URL Session that is downloading image.
	func cancelImageDownload(_ searchResult: SearchResult)
}

/// Prod implementation of `ImageLoader`.
final class ImageProdLoader: ImageLoader {
	static let shared: ImageLoader = ImageProdLoader()
	
	private(set) var imageSessions: [String: URLSessionDataTask] = [:]
	let imageCache: NSCache<NSString, UIImage>
	
	private let urlSession: URLSession
	
	private init() {
		urlSession = URLSession.shared
		imageCache = NSCache()
		
		/// Maximum image cache limit is 100 MB.
		imageCache.totalCostLimit = 100 * 1024 * 1024
	}
	
	/// In order to conserve memory within cache, after fetching image
	/// from network call image data is compressed with lower JPEG quality.
	func downloadImage(_ searchResult: SearchResult) async -> UIImage? {
		let storedImage = imageCache.object(forKey: NSString(string: searchResult.id))
		guard storedImage == nil else {
			return storedImage
		}
		
		guard let imageURL = URL(string: searchResult.imageURL) else {
			return nil
		}
		
		return await withCheckedContinuation { continuation in
			let task = URLSession.shared.dataTask(with: URLRequest(url: imageURL)) { data, _, error in
				guard error == nil, let data else {
					return continuation.resume(returning: nil)
				}
				
				DispatchQueue.global().async { [weak self] in
					if let image = UIImage(data: data),
					   let compressedData = image.jpegData(compressionQuality: 0.2),
					   let compressedImage = UIImage(data: compressedData) {
						self?.imageCache.setObject(compressedImage, forKey: NSString(string: searchResult.id))
						return continuation.resume(returning: compressedImage)
					} else {
						return continuation.resume(returning: nil)
					}
				}
			}
			
			DispatchQueue.main.async {
				self.imageSessions[searchResult.id] = task
			}
			
			task.resume()
		}
	}
	
	func cancelImageDownload(_ searchResult: SearchResult) {
		let id = searchResult.id
		guard let session = imageSessions[id] else {
			return
		}
		
		session.cancel()
		imageSessions[id] = nil
	}
}
