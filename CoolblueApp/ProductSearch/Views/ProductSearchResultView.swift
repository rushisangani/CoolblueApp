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
        case .empty:
            ContentUnavailableView.search(text: viewModel.query)
        case .failed(let error):
            ContentUnavailableView {
                Label("Couldn't load products", systemImage: "exclamationmark.triangle")
            } description: {
                Text(error.message)
            } actions: {
                Button("Try Again") {
                    viewModel.retry()
                }
                .buttonStyle(.borderedProminent)
            }
        case .loaded:
            productList
        }
    }

    private var productList: some View {
        List {
            ForEach(viewModel.products) { product in
                Button {
                    viewModel.showProduct(product)
                } label: {
                    ProductRow(product: product)
                }
                // Keeps the row's own colors instead of tinting its text like a link.
                .buttonStyle(.plain)
                .onAppear {
                    viewModel.loadMoreIfNeeded(after: product)
                }
            }
            switch viewModel.loadMoreState {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
            case .failed(let error):
                VStack(spacing: 8) {
                    Text(error.message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Try Again") {
                        viewModel.retryLoadMore()
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }
}
