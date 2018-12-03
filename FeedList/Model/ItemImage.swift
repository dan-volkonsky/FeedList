import Foundation
import UIKit

struct ItemImage: Codable {
	let image: String
	let width: Int
	let height: Int
	let color: String
}

extension ItemImage {
	func hexStringToUIColor(hex: String) -> UIColor {
		if hex.count != 7 {
			return UIColor.gray
		}
		
		var rgbValue:UInt32 = 0
		Scanner(string: String(hex.suffix(6))).scanHexInt32(&rgbValue)
		
		return UIColor(
			red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
			alpha: CGFloat(1.0)
		)
	}
	
	var uiColor: UIColor {
		return hexStringToUIColor(hex: color)
	}
}
