/// Модель отзыва.
struct Review: Decodable {
    let text: String
    let created: String
    let first_name: String
    let last_name: String
    let rating: Int
    let avatar_url: String?
}
