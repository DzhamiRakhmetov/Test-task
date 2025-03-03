import UIKit

/// Класс, описывающий бизнес-логику экрана отзывов.
final class ReviewsViewModel: NSObject {
    
    /// Замыкание, вызываемое при изменении `state`.
    var onStateChange: ((State) async -> Void)?
    
    private var state: State
    private let reviewsProvider: ReviewsProvider
    private let ratingRenderer: RatingRenderer
    private let decoder: JSONDecoder
    
    // MARK: - Initialization
    
    init(
        state: State = State(),
        reviewsProvider: ReviewsProvider = ReviewsProvider(),
        ratingRenderer: RatingRenderer = RatingRenderer(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.state = state
        self.reviewsProvider = reviewsProvider
        self.ratingRenderer = ratingRenderer
        self.decoder = decoder
    }
}

// MARK: - Internal

extension ReviewsViewModel {
    
    typealias State = ReviewsViewModelState
    
    /// Метод получения отзывов.
    func getReviews() {
        guard state.shouldLoad else { return }
        
        if state.items.isEmpty {
            state.isLoading = true
            
            Task { await onStateChange?(state) }
        }
        
        state.shouldLoad = false
        
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let data = try await self.reviewsProvider.getReviews(offset: self.state.offset)
                gotReviews(data)
            } catch {
                state.shouldLoad = true
            }
            
            self.state.isLoading = false
            await onStateChange?(state)
        }
    }
}

// MARK: - Private

private extension ReviewsViewModel {
    
    /// Метод обработки получения отзывов.
    func gotReviews(_ data: Data) {
        do {
            let reviews = try decoder.decode(Reviews.self, from: data)
            state.items += reviews.items.map(makeReviewItem)
            state.offset += state.limit
            state.totalCount = reviews.count
            state.shouldLoad = state.offset < reviews.count
        } catch {
            state.shouldLoad = true
        }
    }
    
    /// Метод, вызываемый при нажатии на кнопку "Показать полностью...".
    /// Снимает ограничение на количество строк текста отзыва (раскрывает текст).
    func showMoreReview(with id: UUID) {
        guard
            let index = state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == id }),
            var item = state.items[index] as? ReviewItem
        else { return }
        item.maxLines = .zero
        state.items[index] = item
        
        Task { [weak self] in
            guard let self else { return }
            await onStateChange?(state)
        }
    }
}

// MARK: - Items

private extension ReviewsViewModel {
    
    typealias ReviewItem = ReviewCellConfig
    
    func makeReviewItem(_ review: Review) -> ReviewItem {
        let reviewText = review.text.attributed(font: .text)
        let created = review.created.attributed(font: .created, color: .created)
        let item = ReviewItem(
            reviewText: reviewText,
            created: created,
            onTapShowMore: { [unowned self] in self.showMoreReview(with: $0)},
            firstName: review.first_name,
            lastName: review.last_name,
            rating: review.rating,
            avatarURL: URL(string: review.avatar_url ?? "")
        )
        return item
    }
}

// MARK: - UITableViewDataSource

extension ReviewsViewModel: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !state.shouldLoad && state.totalCount > 0 {
            return state.items.count + 1
        } else {
            return state.items.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Если отзывы ещё загружаются
        // или текущий индекс находится в пределах загруженных отзывов (indexPath.row < state.items.count)
        if state.shouldLoad || indexPath.row < state.items.count {
            let config = state.items[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: config.reuseId, for: indexPath)
            config.update(cell: cell)
            return cell
        } else {
            let countConfig = ReviewCountCellConfig(totalCount: state.totalCount)
            let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCountCellConfig.reuseId, for: indexPath)
            countConfig.update(cell: cell)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension ReviewsViewModel: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if state.shouldLoad || indexPath.row < state.items.count {
            return state.items[indexPath.row].height(with: tableView.bounds.size)
        } else {
            let countConfig = ReviewCountCellConfig(totalCount: state.totalCount)
            return countConfig.height(with: tableView.bounds.size)
        }
    }
    
    /// Метод дозапрашивает отзывы, если до конца списка отзывов осталось два с половиной экрана по высоте.
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if shouldLoadNextPage(scrollView: scrollView, targetOffsetY: targetContentOffset.pointee.y) {
            getReviews()
        }
    }
    
    private func shouldLoadNextPage(
        scrollView: UIScrollView,
        targetOffsetY: CGFloat,
        screensToLoadNextPage: Double = 2.5
    ) -> Bool {
        let viewHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let triggerDistance = viewHeight * screensToLoadNextPage
        let remainingDistance = contentHeight - viewHeight - targetOffsetY
        return remainingDistance <= triggerDistance
    }
}
