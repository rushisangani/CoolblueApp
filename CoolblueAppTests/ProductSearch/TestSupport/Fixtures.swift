import Foundation
@testable import CoolblueApp

extension Product {
    // A product with only the fields the view models care about filled in.
    static func stub(id: Int) -> Product {
        Product(
            id: id,
            name: "Product \(id)",
            imageURL: nil,
            reviewAverage: 9,
            reviewCount: 10,
            usps: [],
            price: 100,
            listPrice: nil,
            promo: nil,
            nextDayDelivery: false
        )
    }
}

extension ProductSearchResponse {
    // One page of stub products with the given ids.
    static func stub(ids: [Int], page: Int = 1, pageCount: Int = 1) -> ProductSearchResponse {
        ProductSearchResponse(products: ids.map { Product.stub(id: $0) }, currentPage: page, pageCount: pageCount)
    }
}

enum Fixture {
    // A search page in the API's shape: the first product has every field, with untrimmed text and an
    // unrounded price; the second leaves out the optional list price and promo.
    static let searchPage = Data("""
    {
      "products": [
        {
          "productId": 785359,
          "productName": "  Apple iPhone 6 32GB Grijs ",
          "reviewInformation": {
            "reviews": [],
            "reviewSummary": { "reviewAverage": 9.1, "reviewCount": 952 }
          },
          "USPs": [" 32 GB opslagcapaciteit", "4,7 inch Retina HD scherm ", "iOS 11"],
          "availabilityState": 2,
          "salesPriceIncVat": 369.999,
          "listPriceIncVat": 399,
          "productImage": "https://image.coolblue.nl/300x750/products/818870",
          "promoIcon": { "text": " middenklasse iPhone ", "type": "coolblues-choice" },
          "nextDayDelivery": true
        },
        {
          "productId": 793277,
          "productName": "Apple iPhone X 64GB Space Gray",
          "reviewInformation": {
            "reviews": [],
            "reviewSummary": { "reviewAverage": 9.2, "reviewCount": 209 }
          },
          "USPs": [],
          "availabilityState": 2,
          "salesPriceIncVat": 1079,
          "productImage": "https://image.coolblue.nl/300x750/products/1016563",
          "nextDayDelivery": false
        }
      ],
      "currentPage": 1,
      "pageSize": 24,
      "totalResults": 70,
      "pageCount": 3
    }
    """.utf8)
}
