//
//  NASAApp.swift
//  NASA
//
//  Created by Ismail Elmaliki on 4/30/23.
//

import SwiftUI

@main
struct NASAApp: App {
    var body: some Scene {
        WindowGroup {
			NavigationView {
				ListSearchView()
					.navigationTitle("🚀 NASA Search")
					.navigationBarTitleDisplayMode(.large)
			}
        }
    }
}
