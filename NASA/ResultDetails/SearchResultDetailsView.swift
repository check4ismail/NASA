//
//  SearchResultDetailsView.swift
//  NASA
//
//  Created by Ismail Elmaliki on 5/2/23.
//

import SwiftUI

struct SearchResultDetailsView: View {
    let searchResult: SearchResult
	let image: UIImage?
	
	var body: some View {
		ScrollView {
			LazyVStack(alignment: .leading, spacing: 15) {
				if let image {
					Image(uiImage: image)
						.resizable()
						.frame(width: nil, height: 300)
						.aspectRatio(contentMode: .fill)
					
				}
				
				Text(searchResult.description)
					.font(.system(size: 16))
				
				if let location = searchResult.location {
					Text("**Location**: \(location)")
				}
				
				if let photographer = searchResult.photographer {
					Text("**Photographer**: \(photographer)")
				}
				
				Spacer()
			}
			.navigationTitle(searchResult.title)
			.navigationBarTitleDisplayMode(.large)
			.padding()
		}
    }
}

struct SearchResultDetailsView_Previews: PreviewProvider {
    static var previews: some View {
		SearchResultDetailsView(
			searchResult: SearchResult(
				description: "Here it is",
				title: "Testing"
			),
			image: UIImage(systemName: "folder")
		)
    }
}
