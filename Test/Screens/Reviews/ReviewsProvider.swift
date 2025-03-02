import Foundation

/// Класс для загрузки отзывов.
final class ReviewsProvider {
    private let bundle: Bundle
    
    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }
}

// MARK: - Internal

extension ReviewsProvider {
    
    enum GetReviewsError: Error {
        case badURL
        case badData(Error)
        
    }
    
    func getReviews(offset: Int = 0) async throws -> Data {
        guard let url = bundle.url(forResource: "getReviews.response", withExtension: "json") else {
            throw GetReviewsError.badURL
        }
        
        // Симулируем сетевой запрос - не менять
        usleep(.random(in: 100_000...1_000_000))
        
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            throw GetReviewsError.badData(error)
        }
    }
}
