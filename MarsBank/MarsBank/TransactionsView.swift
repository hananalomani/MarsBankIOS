import SwiftUI

struct Transaction: Identifiable, Codable {
    let id: Int
    let fromAccountNumber: String
    let toAccountNumber: String
    let amount: Double
    let transactionDate: String
}

struct TransactionsView: View {

    let accountNumber: String
    @State private var transactions: [Transaction] = []

    var body: some View {
        List(transactions) { transaction in
            VStack(alignment: .leading, spacing: 8) {
                Text("Amount: \(transaction.amount, specifier: "%.3f") KD")
                    .font(.headline)

                Text("From: \(transaction.fromAccountNumber)")
                Text("To: \(transaction.toAccountNumber)")
                Text("Date: \(transaction.transactionDate)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
        .navigationTitle("Transactions")
        .onAppear {
            loadTransactions()
        }
    }

    func loadTransactions() {
        guard let url = URL(string: "http://127.0.0.1:5023/transactions/\(accountNumber)") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let decoded = try? JSONDecoder().decode([Transaction].self, from: data) {
                    DispatchQueue.main.async {
                        self.transactions = decoded
                    }
                }
            }
        }.resume()
    }
}

#Preview {
    TransactionsView(accountNumber: "123456789")
}
