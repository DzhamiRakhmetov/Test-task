import UIKit

final class ReviewsViewController: UIViewController {
    
    @MainActor
    var reviewsView: ReviewsView? {
        get async {  view as? ReviewsView }
    }
    
    private let viewModel: ReviewsViewModel
    
    // MARK: - Initialization
    
    init(viewModel: ReviewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func loadView() {
        view = makeReviewsView()
        title = "Отзывы"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupPullToRefresh()
        viewModel.getReviews()
    }
}

// MARK: - Private

private extension ReviewsViewController {
    
    func makeReviewsView() -> ReviewsView {
        let reviewsView = ReviewsView()
        reviewsView.tableView.delegate = viewModel
        reviewsView.tableView.dataSource = viewModel
        return reviewsView
    }
    
    func setupViewModel() {
        viewModel.onStateChange = { [weak self] state in
            await self?.reviewsView?.tableView.reloadData()
            
            if state.isLoading {
                await self?.reviewsView?.loadingIndicator.startAnimating()
            } else {
                await self?.reviewsView?.loadingIndicator.stopAnimating()
            }
            
            await self?.reviewsView?.tableView.refreshControl?.endRefreshing()
        }
    }
    
    func setupPullToRefresh() {
        guard let reviewsView = view as? ReviewsView else { return }
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        reviewsView.tableView.refreshControl = refreshControl
    }
    
    @objc func handleRefresh() {
        viewModel.getReviews()
    }
}
