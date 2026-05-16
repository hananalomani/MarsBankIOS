import SwiftUI

struct TransferView: View {

    @State private var accounts: [Account] = []
    @State private var fromAccount = ""
    @State private var toAccount = ""
    @State private var amount = ""
    @State private var message = ""

    var body: some View {

        VStack(spacing: 24) {

            Text("Transfer Money")
                .font(.largeTitle)
                .bold()

            VStack(alignment: .leading, spacing: 12) {

                Text("From Account")
                    .font(.headline)

                Picker("Choose From Account", selection: $fromAccount) {
                    Text("Choose account").tag("")
                    ForEach(accounts) { account in
                        Text("\(account.nickname) • \(account.accountNumber)")
                            .tag(account.accountNumber)
                    }
                }
                .pickerStyle(.menu)

                Text("To Account")
                    .font(.headline)

                Picker("Choose To Account", selection: $toAccount) {
                    Text("Choose account").tag("")
                    ForEach(accounts) { account in
                        Text("\(account.nickname) • \(account.accountNumber)")
                            .tag(account.accountNumber)
                    }
                }
                .pickerStyle(.menu)

                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 280)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .padding(.horizontal)

            Spacer()

            Button("Transfer") {
                transferMoney()
            }
            .padding()
            .frame(width: 260)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(14)

            Text(message)
                .foregroundColor(.blue)
                .font(.headline)

            Spacer()
        }
        .padding(.top, 40)
        .onAppear {
            loadAccounts()
        }
    }

    func loadAccounts() {
        guard let url = URL(string: "http://127.0.0.1:5023/accounts/100000001") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let decoded = try? JSONDecoder().decode([Account].self, from: data) {
                    DispatchQueue.main.async {
                        self.accounts = decoded
                    }
                }
            }
        }.resume()
    }

    func transferMoney() {

        if fromAccount.isEmpty || toAccount.isEmpty {
            message = "Please choose both accounts"
            return
        }

        if fromAccount == toAccount {
            message = "Cannot transfer to same account"
            return
        }

        guard let amountValue = Double(amount), amountValue > 0 else {
            message = "Enter valid amount"
            return
        }

        guard let url = URL(string: "http://127.0.0.1:5023/accounts/transfer") else {
            return
        }

        let body: [String: Any] = [
            "fromAccountNumber": fromAccount,
            "toAccountNumber": toAccount,
            "amount": amountValue
        ]

        let jsonData = try! JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse {

                    if httpResponse.statusCode == 200 {
                        self.message = "Transfer Successful"
                    } else if httpResponse.statusCode == 400 {
                        self.message = "Insufficient balance or invalid transfer"
                    } else {
                        self.message = "Transfer Failed"
                    }

                } else {
                    self.message = "Connection Error"
                }
            }
        }.resume()
    }
}

#Preview {
    TransferView()
}
