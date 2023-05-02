//
//  ImageCache.swift
//  NASA
//
//  Created by Ismail Elmaliki on 5/2/23.
//

import UIKit

final class ImageCache: NSCache<NSString, UIImage> {
	subscript(key: String) -> UIImage? {
		get {
			return object(forKey: NSString(string: key))
		}
		set {
			if let newValue {
				setObject(newValue, forKey: NSString(string: key))
			} else {
				removeObject(forKey: NSString(string: key))
			}
		}
	}
}
