//
//  ReviewCountCell.swift
//  Test
//
//  Created by Dzhami on 27.02.2025.
//
import UIKit

struct ReviewCountCellConfig: TableCellConfig {
    static let reuseId = "ReviewCountCell"
    static let horizontalPadding: CGFloat = 12.0
    static let verticalPadding: CGFloat = 20.0
    static let minimumHeight: CGFloat = 44.0
    
    var totalCount: Int
    var text: NSAttributedString {
        return "Всего отзывов: \(totalCount)".attributed(font: UIFont.systemFont(ofSize: 14), color: .gray)
    }
    
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCountCell else { return }
        cell.countLabel.attributedText = text
        cell.countLabel.textAlignment = .center
    }
    
    func height(with size: CGSize) -> CGFloat {
        let availableWidth = size.width - 2 * Self.horizontalPadding
        let textHeight = text.boundingRect(width: availableWidth, height: .greatestFiniteMagnitude).size.height
        return max(Self.minimumHeight, textHeight + Self.verticalPadding)
    }
}

final class ReviewCountCell: UITableViewCell {
    let countLabel = UILabel()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    private func setupCell() {
        contentView.addSubview(countLabel)
        countLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            countLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
