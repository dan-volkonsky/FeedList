import UIKit

class FeedTableViewController: UITableViewController, UITableViewDataSourcePrefetching {
	
	private let dateFormatter = DateFormatter()
	
	private let fetchClient = FetchClient()
	
	private var feedItems: [FeedItem] = []
	
	private var isFetching: Bool = false
	private var currentPage: Int = 0
	
	private var imageCache: [String: UIImage] = [:]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		dateFormatter.dateFormat = "dd.MM.yyyy"
		
		tableView.prefetchDataSource = self
		
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(refreshItems), for: .valueChanged)
		refreshControl?.beginRefreshing()
		
		loadItems(refresh: true)
	}
	
	// MARK: — UITableViewDataSourcePrefetching
	
	func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		if (indexPaths.contains { $0.row + 1 >= self.feedItems.count }) {
			fetchNextPage();
		}
	}
	
	func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		
	}
	
	// MARK: — UITableViewDataSource
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return feedItems.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FeedTableViewCell.self),
												 for: indexPath) as! FeedTableViewCell
		
		let item = feedItems[indexPath.row]
		updateCell(cell, indexPath, data: item)
		
		return cell
	}
	
	// MARK: — Private methods
	
	private func updateCell(_ cell: FeedTableViewCell, _ indexPath: IndexPath, data: FeedItem) {
		cell.titleLabel.text = "\(data.title)\n\n"
		cell.numLikesLabel.text = "Likes: \(data.likes_count)"
		cell.dateLabel.text = dateFormatter.string(from: data.published)
		cell.thumbImageView.backgroundColor = nil
		cell.thumbImageView.image = nil
		
		if data.images.count == 0 { return }
		
		let itemImage: ItemImage = data.images[0]
		
		cell.thumbImageView.backgroundColor = itemImage.uiColor
		
		if let cachedImage = imageCache[itemImage.image] {
			cell.thumbImageView.image = cachedImage
			return
		}
		
		guard let imageURL: URL = URL(string: itemImage.image) else { return }
		
		let imageTask = URLSession.shared.dataTask(with: imageURL) {
			(data, response, error) in
			
			if let imageData = data {
				self.imageCache[itemImage.image] = UIImage(data: imageData)
				
				DispatchQueue.main.async {
					if let cell = self.tableView.cellForRow(at: indexPath) as? FeedTableViewCell {
						cell.thumbImageView.image = self.imageCache[itemImage.image]
					}
				}
			}
		}
		
		imageTask.resume()
	}
	
	private func fetchNextPage() {
		guard !isFetching else { return }
		currentPage += 1
		loadItems()
	}
	
	@objc
	private func refreshItems() {
		currentPage = 0
		loadItems(refresh: true)
	}
	
	private func loadItems(refresh: Bool = false) {
		isFetching = true
		
		fetchClient.fetchItems(page: currentPage) { (feedPage) in
			
			let newItems: [FeedItem] = feedPage.results
			
			DispatchQueue.main.async {
				if refresh {
					self.feedItems = newItems
					
					self.refreshControl?.endRefreshing()
					self.tableView.reloadData()
				} else {
					var newPaths = [IndexPath]()
					for row in 0..<newItems.count {
						newPaths.append(IndexPath(row: row + self.feedItems.count, section: 0))
					}
					
					self.feedItems += newItems
					
					self.tableView.beginUpdates()
					self.tableView.insertRows(at: newPaths, with: .fade)
					self.tableView.endUpdates()
				}
				
				self.isFetching = false
			}
		}
	}

}
