import Foundation

// Product Data Model
nonisolated struct Product: Identifiable, Sendable {
    let id: Int
    let name: String
    let imageURL: URL?
    let reviewAverage: Double
    let reviewCount: Int
    let usps: [String]
    let price: Decimal
    let listPrice: Decimal?
    let promo: Promo?
    let nextDayDelivery: Bool
}

// Promo
nonisolated struct Promo: Sendable {
    enum Kind: Equatable, Sendable {
        case coolbluesChoice
        case actionPrice
        case unknown(String)
    }

    let text: String
    let kind: Kind
}

// Decodes straight from the API: flattens the nested review summary and cleans up text and prices.
nonisolated extension Product: Decodable {
    private enum CodingKeys: String, CodingKey {
        case productId, productName, reviewInformation, salesPriceIncVat, listPriceIncVat
        case productImage, nextDayDelivery, promoIcon
        case usps = "USPs"
    }

    private enum ReviewInformationKeys: String, CodingKey {
        case reviewSummary
    }

    private enum ReviewSummaryKeys: String, CodingKey {
        case reviewAverage, reviewCount
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let reviewSummary = try container
            .nestedContainer(keyedBy: ReviewInformationKeys.self, forKey: .reviewInformation)
            .nestedContainer(keyedBy: ReviewSummaryKeys.self, forKey: .reviewSummary)

        id = try container.decode(Int.self, forKey: .productId)
        name = try container.decode(String.self, forKey: .productName).trimmed
        imageURL = URL(string: try container.decode(String.self, forKey: .productImage))
        reviewAverage = try reviewSummary.decode(Double.self, forKey: .reviewAverage)
        reviewCount = try reviewSummary.decode(Int.self, forKey: .reviewCount)
        usps = try container.decode([String].self, forKey: .usps).map(\.trimmed)
        price = try container.decode(Decimal.self, forKey: .salesPriceIncVat).roundedToCents
        listPrice = try container.decodeIfPresent(Decimal.self, forKey: .listPriceIncVat)?.roundedToCents
        promo = try container.decodeIfPresent(Promo.self, forKey: .promoIcon)
        nextDayDelivery = try container.decode(Bool.self, forKey: .nextDayDelivery)
    }
}

nonisolated extension Promo: Decodable {
    private enum CodingKeys: String, CodingKey {
        case text, type
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        text = try container.decode(String.self, forKey: .text).trimmed
        // `image` (a review award) and any future types fall back to `.unknown` and show as text.
        kind = switch type {
        case "coolblues-choice": .coolbluesChoice
        case "action-price": .actionPrice
        default: .unknown(type)
        }
    }
}

private nonisolated extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

private nonisolated extension Decimal {
    // Prices are whole cents; rounding here guarantees that whatever precision the API sends.
    var roundedToCents: Decimal {
        var value = self
        var result = Decimal()
        NSDecimalRound(&result, &value, 2, .plain)
        return result
    }
}
