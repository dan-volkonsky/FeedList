import Foundation

struct FeedItem: Codable {
	let id: Int
	let title: String
	let published: Date
	let likes_count: Int
	let images: [ItemImage]
}
