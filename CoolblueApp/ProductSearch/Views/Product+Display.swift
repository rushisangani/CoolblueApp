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

    // Written out because combining the row's children reads "9.1/10" literally and can't express the struck-through price.
    var accessibilityDescription: String {
        var parts: [String] = []
        if let promo {
            parts.append(promo.text)
        }
        parts.append(name)
        parts.append(String(localized: "Rated \(formattedRating) out of 10"))
        parts.append(String(localized: "\(reviewCount) reviews"))
        parts += highlightedUSPs

        if let formattedListPrice {
            parts.append(String(localized: "Price \(formattedPrice), was \(formattedListPrice)"))
        } else {
            parts.append(String(localized: "Price \(formattedPrice)"))
        }

        if nextDayDelivery {
            parts.append(String(localized: "Delivered tomorrow"))
        }
        return parts.joined(separator: ", ")
    }
}
