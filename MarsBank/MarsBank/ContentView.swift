import SwiftUI

struct ContentView: View {

    @State private var username = ""
    @State private var password = ""
    @State private var message = ""
    @State private var isLoggedIn = false
    @State private var customerNumber = 0
    @AppStorage("jwtToken") private var jwtToken = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    MarsPlanetView()
                        .frame(width: 600, height: 600)

                    Text("Mars Bank")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    TextField("Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 280)

                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 280)

                    Button("Login") {
                        login()
                    }
                    .padding()
                    .frame(width: 260)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)

                    Text(message)
                        .foregroundColor(.white)
                }
            }
            .navigationDestination(isPresented: $isLoggedIn) {
                AccountsView(
                    customerNumber: customerNumber,
                    username: username
                )
            }
        }
    }

    func login() {
        guard let url = URL(string: "http://127.0.0.1:5023/login") else {
            return
        }

        let body: [String: Any] = [
            "username": username,
            "password": password
        ]

        let jsonData = try! JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in

            guard let data = data else {
                DispatchQueue.main.async {
                    self.message = "Connection error"
                }
                return
            }

            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    if let number = result["customerNumber"] as? Int {
                        self.customerNumber = number
                    } else if let number = result["customerNumber"] as? Double {
                        self.customerNumber = Int(number)
                    }
                    self.jwtToken = result["token"] as? String ?? ""

                    if !self.jwtToken.isEmpty {
                        self.message = "Authentication Successful"

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.isLoggedIn = true
                        }
                    } else {
                        self.message = "Authentication Failed"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.message = "Invalid password or username"
                }
            }

        }.resume()
    }
}

#Preview {
    ContentView()
}
