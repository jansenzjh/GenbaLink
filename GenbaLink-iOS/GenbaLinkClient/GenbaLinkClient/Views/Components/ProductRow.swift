import SwiftUI
import Combine

struct ProductRow: View {
    let item: ProductSku
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                Text("\(item.category) • \(item.color) • \(item.size)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("\(item.stockLevel) in stock")
                    .foregroundStyle(item.stockLevel <= 5 ? .red : .primary)
                    .bold(item.stockLevel <= 5)
                Text(String(format: "$%.2f", item.price))
                    .font(.caption)
            }
        }
    }
}
