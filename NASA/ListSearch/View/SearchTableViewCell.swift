//
//  SearchTableViewCell.swift
//  NASA
//
//  Created by Ismail Elmaliki on 5/2/23.
//

import Foundation
import UIKit

final class SearchTableViewCell: UITableViewCell {
	static let id = "searchTableViewCell"
	
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
	
	func updateLabel(_ text: String) {
		titleLabel.text = text
	}
	
	func updateImage(_ image: UIImage?) {
		guard let image else {
			return
		}
		
		nasaImageView.backgroundColor = .clear
		nasaImageView.image = image
	}
}
