import SwiftUI

// Everything the search API returns for one product, on its own screen.
struct ProductDetailView: View {
    let product: Product

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                RemoteImage(url: product.imageURL)
                    .frame(height: 280)

                if let promo = product.promo {
                    Text(promo.text)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(product.isDiscounted ? .orange : .blue)
                }

                Text(product.name)
                    .font(.title2.weight(.semibold))

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("\(product.formattedRating)/10")
                    Text("(\(product.reviewCount) reviews)")
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(product.formattedPrice)
                        .font(.title.weight(.bold))
                    if let formattedListPrice = product.formattedListPrice {
                        Text(formattedListPrice)
                            .strikethrough()
                            .foregroundStyle(.secondary)
                    }
                }

                if product.nextDayDelivery {
                    Label("Delivered tomorrow", systemImage: "shippingbox")
                        .foregroundStyle(.green)
                }

                // All USPs here; the row only shows the first few.
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(product.usps, id: \.self) { usp in
                        Label(usp, systemImage: "checkmark")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding()
        }
        .accessibilityIdentifier("productDetail")
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(
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
    }
}
