//
//  SearchTableViewCell.swift
//  NASA
//
//  Created by Ismail Elmaliki on 5/2/23.
//

import Foundation
import UIKit

/// Individual cell for search result.
///
/// Each cell displays an image and the title of the search result. If an image is not found, then a gray-default circle is displayed.
final class SearchTableViewCell: UITableViewCell {
	/// Unique cell identifier.
	static let id = "searchTableViewCell"
	
	var reuseCompletion: (() -> ())?
	
	override func prepareForReuse() {
		nasaImageView.image = nil
		nasaImageView.backgroundColor = .gray
		reuseCompletion?()
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		selectionStyle = .none
		setupView()
		setupLayout()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private lazy var nasaImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.layer.cornerRadius = 30
		imageView.layer.masksToBounds = true
		imageView.backgroundColor = .gray
		return imageView
	}()
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.font = .systemFont(ofSize: 16)
		return label
	}()
	
	private lazy var stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.alignment = .center
		stackView.axis = .horizontal
		return stackView
	}()
	
	private func setupView() {
		stackView.addArrangedSubview(nasaImageView)
		stackView.addArrangedSubview(titleLabel)
		stackView.setCustomSpacing(10, after: nasaImageView)
		
		contentView.addSubview(stackView)
	}
	
	private func setupLayout() {
		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
			
			nasaImageView.heightAnchor.constraint(equalToConstant: 60),
			nasaImageView.widthAnchor.constraint(equalTo: nasaImageView.heightAnchor),
		])
		
	}
	
	/// Updates `titleLabel` text.
	func updateLabel(_ text: String) {
		titleLabel.text = text
	}
	
	/// Updates NASA Image.
	func updateImage(_ image: UIImage?) {
		guard let image else {
			return
		}
		
		nasaImageView.backgroundColor = .clear
		nasaImageView.image = image
	}
}
