import Foundation

class FetchClient {
	
	private let baseURL: URL = URL(string: "http://api.flatun.com/api/feed_item/")!
	
	func fetchItems(page: Int = 0, completion: @escaping (FeedPage) -> Void) {
		
		let urlString: String = "\(baseURL)?page=\(page + 1)"
		
		let dataTask: URLSessionTask = URLSession.shared.dataTask(with: URL(string: urlString)!) {
			(data, response, error) in
			
			guard let httpResponse = response as? HTTPURLResponse else { return }
			
			switch (httpResponse.statusCode) {
				case 200:
					let decoder: JSONDecoder = JSONDecoder()
					decoder.dateDecodingStrategy = .iso8601
					
					let feedPage = try! decoder.decode(FeedPage.self, from: data!)
					
					completion(feedPage)
					
					break
			
				default:
					print("FETCH request got response \(httpResponse.statusCode)")
					break;
			}
		}
		
		dataTask.resume()
	}
	
}
