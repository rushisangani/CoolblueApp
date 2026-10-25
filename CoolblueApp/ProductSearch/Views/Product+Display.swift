import Foundation

// Formatting for product rows to display
extension Product {
    // The API has no currency field; prices are assumed to be euros.
    private static let currency = Decimal.FormatStyle.Currency(code: "EUR")

    var formattedPrice: String {
        price.formatted(Self.currency)
    }
    var formattedListPrice: String? {
        listPrice?.formatted(Self.currency)
    }
    var formattedRating: String {
        reviewAverage.formatted(.number.precision(.fractionLength(1)))
    }
    var highlightedUSPs: ArraySlice<String> {
        usps.prefix(3)
    }
    var isDiscounted: Bool {
        promo?.kind == .actionPrice
    }
}
