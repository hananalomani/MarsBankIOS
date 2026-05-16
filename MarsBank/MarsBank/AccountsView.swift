import SwiftUI

struct Account: Identifiable, Codable, Hashable {

    var id: String { accountNumber }

    let customerNumber: Int
    let accountNumber: String
    let balance: Double
    let nickname: String
}

struct AccountsView: View {

    let customerNumber: Int
    let username: String

    @State private var accounts: [Account] = []
    @State private var totalBalance: Double = 0

    @State private var selectedTransactionAccount: String? = nil
    @State private var selectedEditAccount: Account? = nil

    var body: some View {

        ZStack(alignment: .bottomTrailing) {

            ScrollView {

                VStack(spacing: 20) {

                    VStack(alignment: .leading, spacing: 8) {

                        Text("Total Balance")
                            .font(.headline)
                            .foregroundColor(.gray)

                        Text("\(totalBalance, specifier: "%.3f") KD")
                            .font(.largeTitle)
                            .bold()
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.horizontal)

                    ForEach(accounts) { account in

                        VStack(alignment: .leading, spacing: 16) {

                            HStack {

                                Text(account.nickname)
                                    .font(.headline)
                                    .foregroundColor(.white)

                                Spacer()

                                Button {
                                    selectedTransactionAccount = nil
                                    selectedEditAccount = account
                                } label: {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }

                            Text("•••• \(account.accountNumber.suffix(4))")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)

                            Text("Balance")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))

                            Text("\(account.balance, specifier: "%.3f") KD")
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)

                            Button {
                                selectedEditAccount = nil
                                selectedTransactionAccount = account.accountNumber
                            } label: {
                                Text("View Transactions")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(10)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.black, Color.gray],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(22)
                        .shadow(radius: 6)
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 90)
                }
            }

            NavigationLink {
                TransferView()
            } label: {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.green)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            .padding()
        }
        .navigationDestination(item: $selectedTransactionAccount) { accountNumber in
            TransactionsView(accountNumber: accountNumber)
        }
        .navigationDestination(item: $selectedEditAccount) { account in
            EditNicknameView(
                accountNumber: account.accountNumber,
                nickname: account.nickname
            )
        }
        .navigationTitle("My Accounts")
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text("Hello, \(username)")
                        .font(.headline)

                    Text("Customer Number: \(String(customerNumber))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            loadAccounts()
            loadTotalBalance()
        }
    }

    func loadAccounts() {

        guard let url = URL(
            string: "http://127.0.0.1:5023/accounts/\(customerNumber)"
        ) else {
            return
        }

        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let data = data {

                if let decodedAccounts =
                    try? JSONDecoder().decode([Account].self, from: data) {

                    DispatchQueue.main.async {
                        self.accounts = decodedAccounts
                    }
                }
            }

        }.resume()
    }

    func loadTotalBalance() {

        guard let url = URL(
            string: "http://127.0.0.1:5023/accounts/total/\(customerNumber)"
        ) else {
            return
        }

        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in

            guard let data = data else {
                return
            }

            if let json =
                try? JSONSerialization.jsonObject(with: data)
                as? [String: Any] {

                DispatchQueue.main.async {
                    self.totalBalance =
                        json["totalBalance"] as? Double ?? 0
                }
            }

        }.resume()
    }
}

#Preview {
    NavigationStack {
        AccountsView(
            customerNumber: 100000001,
            username: "Hanan"
        )
    }
}
