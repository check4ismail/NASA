//
//  ListSearchView.swift
//  NASA
//
//  Created by Ismail Elmaliki on 5/2/23.
//

import SwiftUI

struct ListSearchView: UIViewControllerRepresentable {	
	func makeUIViewController(context: Context) -> some UIViewController {
		return ListSearchViewController(viewModel: ListSearchVMImplementer())
	}
	
	func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
		
	}
}
