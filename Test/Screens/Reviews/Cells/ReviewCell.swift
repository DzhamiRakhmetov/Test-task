import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {
    static let reuseId = String(describing: ReviewCellConfig.self)
    
    let id = UUID()
    let reviewText: NSAttributedString
    var maxLines = 3
    let created: NSAttributedString
    let onTapShowMore: (UUID) -> Void
    
    let firstName: String
    let lastName: String
    let rating: Int
    let avatarURL: URL?
    
    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewCellLayout()
}

// MARK: - TableCellConfig

extension ReviewCellConfig: TableCellConfig {

    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCell else { return }
        let renderer = RatingRenderer()
        
        if let url = avatarURL {
            cell.avatarImageView.setImage(from: url.absoluteString, placeholder: UIImage(named: "avatar"))
        } else {
            cell.avatarImageView.image = UIImage(named: "avatar")
        }
        
        cell.nameLabel.text = "\(firstName) \(lastName)"
        cell.ratingImageView.image = renderer.ratingImage(rating)
        cell.reviewTextLabel.attributedText = reviewText
        cell.reviewTextLabel.numberOfLines = maxLines
        cell.createdLabel.attributedText = created
        cell.config = self
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }

}

// MARK: - Private

private extension ReviewCellConfig {
    static let showMoreText = "Показать полностью..."
        .attributed(font: .showMore, color: .showMore)
}

// MARK: - Cell

final class ReviewCell: UITableViewCell {
    fileprivate var config: Config?
    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate let showMoreButton = UIButton()
    fileprivate let avatarImageView = UIImageView()
    fileprivate let nameLabel = UILabel()
    fileprivate let ratingImageView = UIImageView()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        avatarImageView.frame = layout.avatarImageViewFrame
        nameLabel.frame = layout.nameLabelFrame
        ratingImageView.frame = layout.ratingImageViewFrame
        reviewTextLabel.frame = layout.reviewTextLabelFrame
        createdLabel.frame = layout.createdLabelFrame
        showMoreButton.frame = layout.showMoreButtonFrame
    }
    
    override func prepareForReuse() {
         super.prepareForReuse()
        
        avatarImageView.image = nil
        nameLabel.text = nil
        ratingImageView.image = nil
        reviewTextLabel.attributedText = nil
        createdLabel.attributedText = nil
     }
}

// MARK: - Private

private extension ReviewCell {
    func setupCell() {
        setupAvatarImageView()
        setupNameLabel()
        setupRatingImageView()
        setupReviewTextLabel()
        setupCreatedLabel()
        setupShowMoreButton()
    }
    
    func setupAvatarImageView() {
        contentView.addSubview(avatarImageView)
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = ReviewCellLayout.avatarCornerRadius
        avatarImageView.clipsToBounds = true
    }
    
    func setupNameLabel() {
        contentView.addSubview(nameLabel)
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.textColor = .black
    }
    
    func setupRatingImageView() {
        contentView.addSubview(ratingImageView)
        ratingImageView.contentMode = .scaleAspectFit
    }

    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
        reviewTextLabel.lineBreakMode = .byWordWrapping
    }

    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
    }

    func setupShowMoreButton() {
        contentView.addSubview(showMoreButton)
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
        showMoreButton.addTarget(self, action: #selector(showMoreButtonTapped), for: .touchUpInside)
    }
    
    @objc private func showMoreButtonTapped() {
        guard let config = config else { return }
        config.onTapShowMore(config.id)
    }
}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {
    
    // MARK: - Размеры
    
    fileprivate static let avatarSize = CGSize(width: 36.0, height: 36.0)
    fileprivate static let avatarCornerRadius = 18.0
    fileprivate static let photoCornerRadius = 8.0
    
    private static let photoSize = CGSize(width: 55.0, height: 66.0)
    private static let showMoreButtonSize = Config.showMoreText.size()
    
    // MARK: - Фреймы
    private(set) var avatarImageViewFrame = CGRect.zero
    private(set) var reviewTextLabelFrame = CGRect.zero
    private(set) var showMoreButtonFrame = CGRect.zero
    private(set) var createdLabelFrame = CGRect.zero
    private(set) var nameLabelFrame: CGRect = .zero
    private(set) var ratingImageViewFrame: CGRect = .zero
    
    // MARK: - Отступы
    
    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)
    private let avatarToUsernameSpacing = 10.0
    private let usernameToRatingSpacing = 6.0
    private let ratingToTextSpacing = 6.0
    private let ratingToPhotosSpacing = 10.0
    private let photosSpacing = 8.0
    private let photosToTextSpacing = 10.0
    private let reviewTextToCreatedSpacing = 6.0
    private let showMoreToCreatedSpacing = 6.0
    
    // MARK: - Расчёт фреймов и высоты ячейки
    
    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        // Ширина области контента (без левых/правых insets)
        let contentWidth = maxWidth - insets.left - insets.right
        var currentY = insets.top
        var showShowMoreButton = false
        
        // 1. Аватар слева
        avatarImageViewFrame = CGRect(
            x: insets.left,
            y: currentY,
            width: Self.avatarSize.width,
            height: Self.avatarSize.height
        )
        
        // 2. Определяем X и ширину для остальных элементов, чтобы они были правее аватара
        let contentX = avatarImageViewFrame.maxX + avatarToUsernameSpacing
        let rightBlockWidth = contentWidth - (Self.avatarSize.width + avatarToUsernameSpacing)
        
        // 3. Имя (на уровне аватара)
        let nameFont = UIFont.boldSystemFont(ofSize: 16)
        let nameHeight = nameFont.lineHeight
        nameLabelFrame = CGRect(
            x: contentX,
            y: currentY,
            width: rightBlockWidth,
            height: nameHeight
        )
        currentY = nameLabelFrame.maxY + usernameToRatingSpacing
        
        // 4. Рейтинг (под именем)
        // Вычисляем размеры рейтингового изображения на основе конфигурации
        let defaultRatingConfig = RatingRendererConfig.default()
        let starWidth = defaultRatingConfig.starImage.size.width    // 16.0
        let spacing = defaultRatingConfig.spacing                     // 1.0
        let numberOfStars = CGFloat(defaultRatingConfig.ratingRange.upperBound) // 5
        let computedRatingImageWidth = (starWidth + spacing) * numberOfStars - spacing
        let computedRatingImageHeight = defaultRatingConfig.starImage.size.height  // 16.0
        
        ratingImageViewFrame = CGRect(
            x: contentX,
            y: currentY,
            width: computedRatingImageWidth,
            height: computedRatingImageHeight
        )
        currentY = ratingImageViewFrame.maxY + ratingToTextSpacing
        
        // 5. Текст отзыва
        if !config.reviewText.isEmpty() {
            let lineHeight = config.reviewText.font()?.lineHeight ?? 0
            let currentTextHeight = lineHeight * CGFloat(config.maxLines)
            let actualTextHeight = config.reviewText.boundingRect(width: rightBlockWidth).size.height
            
            // Нужно ли показывать "Показать полностью..."
            showShowMoreButton = (config.maxLines != 0) && (actualTextHeight > currentTextHeight)
            
            let textSize = config.reviewText.boundingRect(width: rightBlockWidth, height: currentTextHeight).size
            reviewTextLabelFrame = CGRect(
                origin: CGPoint(x: contentX, y: currentY),
                size: textSize
            )
            currentY = reviewTextLabelFrame.maxY + reviewTextToCreatedSpacing
        }
        
        // 6. Кнопка "Показать полностью..."
        if showShowMoreButton {
            showMoreButtonFrame = CGRect(
                origin: CGPoint(x: contentX, y: currentY),
                size: Self.showMoreButtonSize
            )
            currentY = showMoreButtonFrame.maxY + showMoreToCreatedSpacing
        } else {
            showMoreButtonFrame = .zero
        }
        
        // 7. Время создания
        let createdSize = config.created.boundingRect(width: rightBlockWidth).size
        createdLabelFrame = CGRect(
            x: contentX,
            y: currentY,
            width: createdSize.width,
            height: createdSize.height
        )
        currentY = createdLabelFrame.maxY + insets.bottom
        
        return currentY
    }
}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Layout = ReviewCellLayout
