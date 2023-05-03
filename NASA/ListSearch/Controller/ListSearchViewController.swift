//
//  ListSearchViewController.swift
//  NASA
//
//  Created by Ismail Elmaliki on 5/2/23.
//

import SwiftUI
import UIKit

typealias Delegates = UISearchBarDelegate & UITextFieldDelegate & UITableViewDataSource & UITableViewDelegate
final class ListSearchViewController<T: ListSearchViewModel>: UIViewController, Delegates {
	private let viewModel: ListSearchViewModel
	
	init(viewModel: T) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	/// Vertical container stack view.
	private lazy var stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = 10
		
		return stackView
	}()
	
	/// Search bar to perform a query.
	private lazy var searchBar: UISearchBar = {
		let searchBar = UISearchBar()
		searchBar.placeholder = "Search"
		searchBar.translatesAutoresizingMaskIntoConstraints = false
		return searchBar
	}()
	
	/// Label that appears to user when query returns no results.
	private lazy var noResultsLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.isHidden = true
		label.numberOfLines = 0
		label.font = .systemFont(ofSize: 22)
		return label
	}()
	
	/// List of query results.
	private lazy var tableView: UITableView = {
		let tableView = UITableView()
		tableView.translatesAutoresizingMaskIntoConstraints = false
		return tableView
	}()
	
	override func viewDidLoad() {
		setupView()
		setupLayout()
	}
	
	/// Executes query search search.
	///
	/// Depending on search results, the tableView is either reloaded or updated row-by-row.
	private func executeSearch() {
		Task {
			/// Get current row count of search results
			let startingRow = viewModel.searchResults.count
			
			/// Execute search query network request
			let loadAction = await viewModel.performSearch()
			
			
			updateNoResults()
			
			switch loadAction {
			case .reloadAll:
				/// Completely new `searchResults` means tableView should be reloaded.
				tableView.reloadData()
				tableView.layoutIfNeeded()
				tableView.setContentOffset(.zero, animated: false)
			case .reloadRows:
				/// Paging through existing `searchResults` will reload tableView rows using batch updates.
				let endingRow = viewModel.searchResults.count
				tableView.performBatchUpdates {
					for row in startingRow..<endingRow {
						tableView.insertRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
					}
				}
			default:
				break
			}
		}
	}
	
	/// Hides and un-hides `noResultsLabel` depending on whether or not search results are empty.
	private func updateNoResults() {
		if viewModel.searchResults.isEmpty {
			noResultsLabel.text = viewModel.noResultsText
			noResultsLabel.isHidden = false
		} else {
			noResultsLabel.isHidden = true
		}
	}
	
	/// Setup subviews.
	private func setupView() {
		searchBar.searchTextField.delegate = self
		searchBar.delegate = self
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.estimatedRowHeight = UITableView.automaticDimension
		tableView.rowHeight = UITableView.automaticDimension
		tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.id)
		
		stackView.addArrangedSubview(searchBar)
		stackView.addArrangedSubview(noResultsLabel)
		stackView.addArrangedSubview(tableView)
		
		view.addSubview(stackView)
	}
	
	/// Setup auto-layout constraints.
	private func setupLayout() {
		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
			stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
			stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
			stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
		])
	}
	
	// MARK: Search Bar and UITextField Delegate
	
	func textFieldShouldClear(_ textField: UITextField) -> Bool {
		viewModel.clearResults()
		tableView.reloadData()
		noResultsLabel.isHidden = true
		
		DispatchQueue.main.async {
			self.searchBar.resignFirstResponder()
		}
		
		return true
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		if let query = searchBar.text,
			viewModel.currentSearchText != query {
			viewModel.setSearch(with: query)
			executeSearch()
		}
		
		searchBar.resignFirstResponder()
	}
	
	// MARK: UITableView Delegate
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.searchResults.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.id) as! SearchTableViewCell
		let searchResult = viewModel.searchResults[indexPath.row]
		cell.updateLabel(searchResult.title)
		
		/// Download image
		Task {
			let image = await viewModel.imageLoader.downloadImage(searchResult)
			cell.updateImage(image)
		}
		
		/// Cancel image download during `prepareForReuse` function call.
		cell.reuseCompletion = { [weak self] in
			self?.viewModel.imageLoader.cancelImageDownload(searchResult)
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let rowDifference = viewModel.searchResults.count - indexPath.row
		
		/// If the last 15th row is being displayed, then page through more results
		/// so user can view rows ahead of time.
		guard rowDifference == 15 else {
			return
		}
		
		executeSearch()
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let searchResult = viewModel.searchResults[indexPath.row]
		let image = viewModel.imageLoader.imageCache[searchResult.id]
		
		let detailsView = UIHostingController(rootView: SearchResultDetailsView(searchResult: searchResult, image: image))
		navigationController?.pushViewController(detailsView, animated: true)
	}
}
