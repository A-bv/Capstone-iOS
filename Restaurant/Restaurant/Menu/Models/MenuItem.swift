struct MenuItem: Decodable {
	let title: String
	let image: String
	let price: String
	let itemDescription: String?
	
	private enum CodingKeys: String, CodingKey {
		case title, image, price, itemDescription
	}
}
