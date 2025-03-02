import UIKit

final class ReviewsView: UIView {
    
    let loadingIndicator = UIActivityIndicatorView(style: .large)
    let tableView = UITableView()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds.inset(by: safeAreaInsets)
        loadingIndicator.center = center
    }
}

// MARK: - Private

private extension ReviewsView {

    func setupView() {
        backgroundColor = .systemBackground
        setupTableView()
        addSubview(loadingIndicator)
        loadingIndicator.hidesWhenStopped = true
    }

    func setupTableView() {
        addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCellConfig.reuseId)
        tableView.register(ReviewCountCell.self, forCellReuseIdentifier: ReviewCountCellConfig.reuseId)
    }
}
