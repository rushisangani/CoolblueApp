import Foundation
import Testing
@testable import CoolblueApp

struct ProductDecodingTests {
    private func decodePage() throws -> ProductSearchResponse {
        try JSONDecoder().decode(ProductSearchResponse.self, from: Fixture.searchPage)
    }

    @Test func decodesThePageInfo() throws {
        let page = try decodePage()

        #expect(page.currentPage == 1)
        #expect(page.pageCount == 3)
        #expect(page.products.map(\.id) == [785359, 793277])
    }

    @Test func decodesAndCleansUpAFullProduct() throws {
        let product = try decodePage().products[0]

        #expect(product.name == "Apple iPhone 6 32GB Grijs")
        #expect(product.imageURL == URL(string: "https://image.coolblue.nl/300x750/products/818870"))
        #expect(product.reviewAverage == 9.1)
        #expect(product.reviewCount == 952)
        #expect(product.usps == ["32 GB opslagcapaciteit", "4,7 inch Retina HD scherm", "iOS 11"])
        #expect(product.price == 370)
        #expect(product.listPrice == 399)
        #expect(product.promo == Promo(text: "middenklasse iPhone", kind: .coolbluesChoice))
        #expect(product.nextDayDelivery)
    }

    @Test func missingOptionalFieldsDecodeAsNil() throws {
        let product = try decodePage().products[1]

        #expect(product.listPrice == nil)
        #expect(product.promo == nil)
        #expect(product.usps.isEmpty)
        #expect(!product.nextDayDelivery)
    }

    // `image` is a real API type the app doesn't style, so it's kept as unknown.
    @Test(arguments: [
        ("coolblues-choice", Promo.Kind.coolbluesChoice),
        ("action-price", .actionPrice),
        ("image", .unknown("image")),
    ])
    func decodesPromoTypes(type: String, kind: Promo.Kind) throws {
        let json = Data(#"{ "text": "Promo", "type": "\#(type)" }"#.utf8)

        let promo = try JSONDecoder().decode(Promo.self, from: json)

        #expect(promo.kind == kind)
    }
}
