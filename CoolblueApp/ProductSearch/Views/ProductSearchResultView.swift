import SwiftUI

struct ProductSearchResultView: View {
    @State private var viewModel: ProductSearchResultViewModel

    // SwiftUI may call this again on re-render; `@State` keeps the first view model and ignores later ones.
    init(viewModel: ProductSearchResultViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle(viewModel.query)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.start()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
        case .loaded:
            productList
        }
    }

    private var productList: some View {
        List(viewModel.products) { product in
            ProductRow(product: product)
        }
        .listStyle(.plain)
    }
}
