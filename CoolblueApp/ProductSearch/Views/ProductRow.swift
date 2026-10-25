import SwiftUI
import ImageLoading

struct ProductRow: View {
    let product: Product

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RemoteImage(url: product.imageURL)
                .frame(width: 88, height: 88)

            VStack(alignment: .leading, spacing: 6) {
                if let promo = product.promo {
                    Text(promo.text)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(product.isDiscounted ? .orange : .blue)
                }

                Text(product.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)

                rating

                VStack(alignment: .leading, spacing: 2) {
                    ForEach(product.highlightedUSPs, id: \.self) { usp in
                        Label(usp, systemImage: "checkmark")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }

                price

                if product.nextDayDelivery {
                    Label("Delivered tomorrow", systemImage: "shippingbox")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(product.accessibilityDescription)
    }

    private var rating: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            Text("\(product.formattedRating)/10")
            Text("(\(product.reviewCount))")
                .foregroundStyle(.secondary)
        }
        .font(.caption)
    }

    private var price: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(product.formattedPrice)
                .font(.headline)
            if let formattedListPrice = product.formattedListPrice {
                Text(formattedListPrice)
                    .font(.caption)
                    .strikethrough()
                    .foregroundStyle(.secondary)
            }
        }
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
