//
//  ViewController.swift
//  RAG Bot
//
//  Created by Srihan Vege on 8/5/25.
//

import SwiftUI

struct ContentView: View {
    @State private var userInput: String = ""
    @State private var messages: [String] = []

    var body: some View {
        VStack {
            Text("Sports Chatbot")
                .font(.title)
                .padding(.top)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(messages, id: \.self) { message in
                        Text(message)
                            .padding()
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity, alignment: message.starts(with: "You:") ? .trailing : .leading)
                    }
                }
                .padding()
            }

            HStack {
                TextField("Ask a sports question...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .padding()
                }
                .disabled(userInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
        }
    }

    func sendMessage() {
        let trimmed = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        messages.append("You: \(trimmed)")

        let queryData = ["query": trimmed]
        guard let url = URL(string: "http://127.0.0.1:8000/ask"),
              let jsonData = try? JSONSerialization.data(withJSONObject: queryData) else {
            messages.append("Bot: Failed to create request.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data,
                  let result = try? JSONDecoder().decode([String: String].self, from: data),
                  let answer = result["answer"] else {
                DispatchQueue.main.async {
                    messages.append("Bot: Failed to get a response.")
                }
                return
            }

            DispatchQueue.main.async {
                messages.append("Bot: \(answer)")
            }
        }.resume()

        userInput = ""
    }
}

#Preview {
    ContentView()
}
