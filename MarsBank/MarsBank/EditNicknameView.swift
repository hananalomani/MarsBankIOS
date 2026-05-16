import SwiftUI

struct EditNicknameView: View {

    let accountNumber: String
    @State var nickname: String

    @Environment(\.dismiss) var dismiss

    @State private var message = ""

    var body: some View {

        VStack(spacing: 20) {

            Text("Edit Account Name")
                .font(.title2)
                .bold()

            TextField("Nickname", text: $nickname)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Save") {
                updateNickname()
            }
            .padding()
            .frame(width: 200)
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(12)

            Text(message)
                .foregroundColor(.gray)

            Spacer()
        }
        .padding(.top, 40)
    }

    func updateNickname() {

        guard let url =
            URL(string: "http://127.0.0.1:5023/accounts/nickname") else {
            return
        }

        let body: [String: Any] = [
            "accountNumber": accountNumber,
            "nickname": nickname
        ]

        let jsonData =
            try! JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)

        request.httpMethod = "PUT"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) {
            data, response, error in

            DispatchQueue.main.async {

                self.message = "Updated Successfully"

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    dismiss()
                }
            }

        }.resume()
    }
}

#Preview {
    EditNicknameView(
        accountNumber: "123456789",
        nickname: "Savings"
    )
}
