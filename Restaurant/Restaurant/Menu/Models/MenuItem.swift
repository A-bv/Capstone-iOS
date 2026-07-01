struct MenuItem: Decodable {
	let title: String
	let image: String
	let price: String
	let itemDescription: String?
	let category: String?

	private enum CodingKeys: String, CodingKey {
		case title, image, price, category
		case itemDescription = "description"
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		title = try container.decode(String.self, forKey: .title)
		image = try container.decode(String.self, forKey: .image)
		itemDescription = try container.decodeIfPresent(String.self, forKey: .itemDescription)
		category = try container.decodeIfPresent(String.self, forKey: .category)

		// The API has shipped `price` both as a JSON string ("10") and as a
		// number (10 or 9.99). Accept either so one format change doesn't
		// break the whole menu decode.
		if let priceString = try? container.decode(String.self, forKey: .price) {
			price = priceString
		} else if let priceInt = try? container.decode(Int.self, forKey: .price) {
			price = String(priceInt)
		} else {
			price = String(try container.decode(Double.self, forKey: .price))
		}
	}
}
