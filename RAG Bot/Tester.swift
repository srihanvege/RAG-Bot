//
//  Tester.swift
//  RAG Bot
//
//  Created by Srihan Vege on 8/5/25.
//

import OpenAISwift
import Foundation

final class APICaller {
    static let shared = APICaller()

    private var client: OpenAISwift?

    private init() {}

    public func setup() {
        let config = OpenAISwift.Config(
            baseURL: "https://api.openai.com/v1",
            endpointPrivider: OpenAIEndpointProvider(source: .openAI),
            session: .shared,
            authorizeRequest: { request in
                request.setValue("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", forHTTPHeaderField: "Authorization")
            }
        )

        self.client = OpenAISwift(config: config)
    }

    public func getResponse(input: String,
                            completion: @escaping (Result<String, Error>) -> Void) {
        client?.sendCompletion(with: input) { result in
            switch result {
            case .success(let model):
                let output = model.choices?.first?.text ?? "No response"
                completion(.success(output))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}


