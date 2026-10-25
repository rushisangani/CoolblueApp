import SwiftUI

struct ProductRow: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(product.name)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)

            Text(product.price, format: .currency(code: "EUR"))
                .font(.headline)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ProductRow(
        product: Product(
            id: 785359,
            name: "Apple iPhone 6 32GB Grijs",
            imageURL: URL(string: "https://image.coolblue.nl/300x750/products/818870"),
            reviewAverage: 9.1,
            reviewCount: 952,
            usps: ["32 GB opslagcapaciteit", "4,7 inch Retina HD scherm", "iOS 11"],
            price: 369,
            listPrice: nil,
            promo: Promo(text: "middenklasse iPhone", kind: .coolbluesChoice),
            nextDayDelivery: true
        )
    )
    .padding()
}
