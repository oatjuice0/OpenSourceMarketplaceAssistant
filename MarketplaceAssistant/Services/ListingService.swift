import Foundation
import UIKit

struct ListingResponse: Codable {
    let title: String
    let price: Int
    let description: String
}

class ListingService {
    enum ServiceError: LocalizedError {
        case noAPIKey
        case noInternet
        case apiError(String)
        case invalidResponse

        var errorDescription: String? {
            switch self {
            case .noAPIKey: return "Please add your API key in Settings first."
            case .noInternet: return "No internet connection. Please try again."
            case .apiError(let msg): return msg
            case .invalidResponse: return "Could not parse the AI response. Please try again."
            }
        }
    }

    func generateListing(
        image: UIImage,
        category: ListingCategory?,
        sellingStyle: SellingStyle,
        pricingStrategy: PricingStrategy,
        conditionDetail: ConditionDetail,
        logistics: Set<LogisticsOption>
    ) async throws -> ListingResponse {
        let settings = SettingsManager.shared
        guard settings.hasAPIKey else { throw ServiceError.noAPIKey }

        let prompt = buildPrompt(
            category: category,
            sellingStyle: sellingStyle,
            pricingStrategy: pricingStrategy,
            conditionDetail: conditionDetail,
            logistics: logistics
        )

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw ServiceError.invalidResponse
        }
        let base64Image = imageData.base64EncodedString()

        switch settings.apiProvider {
        case .google:
            return try await callGemini(prompt: prompt, base64Image: base64Image, apiKey: settings.apiKey)
        case .openai:
            return try await callOpenAI(prompt: prompt, base64Image: base64Image, apiKey: settings.apiKey)
        case .anthropic:
            return try await callAnthropic(prompt: prompt, base64Image: base64Image, apiKey: settings.apiKey)
        }
    }

    // MARK: - Google Gemini (free tier: 15 requests/min, 1M tokens/min)

    private func callGemini(prompt: String, base64Image: String, apiKey: String) async throws -> ListingResponse {
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60

        let body: [String: Any] = [
            "systemInstruction": [
                "parts": [["text": prompt]]
            ],
            "contents": [
                [
                    "parts": [
                        [
                            "inlineData": [
                                "mimeType": "image/jpeg",
                                "data": base64Image
                            ]
                        ],
                        [
                            "text": "Generate a Facebook Marketplace listing for this item. Return only valid JSON."
                        ]
                    ]
                ]
            ] as [[String: Any]]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await performRequest(request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.invalidResponse
        }

        if httpResponse.statusCode != 200 {
            if let errorBody = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorBody["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw ServiceError.apiError(message)
            }
            throw ServiceError.apiError("API returned status \(httpResponse.statusCode)")
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let first = candidates.first,
              let content = first["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let textPart = parts.first,
              let text = textPart["text"] as? String else {
            throw ServiceError.invalidResponse
        }

        return try parseListingJSON(from: text)
    }

    // MARK: - OpenAI

    private func callOpenAI(prompt: String, base64Image: String, apiKey: String) async throws -> ListingResponse {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60

        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": prompt],
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "image_url",
                            "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]
                        ],
                        [
                            "type": "text",
                            "text": "Generate a Facebook Marketplace listing for this item. Return only valid JSON."
                        ]
                    ] as [[String: Any]]
                ]
            ] as [[String: Any]],
            "max_tokens": 1000
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await performRequest(request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.invalidResponse
        }

        if httpResponse.statusCode != 200 {
            if let errorBody = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorBody["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw ServiceError.apiError(message)
            }
            throw ServiceError.apiError("API returned status \(httpResponse.statusCode)")
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let first = choices.first,
              let message = first["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw ServiceError.invalidResponse
        }

        return try parseListingJSON(from: content)
    }

    // MARK: - Anthropic

    private func callAnthropic(prompt: String, base64Image: String, apiKey: String) async throws -> ListingResponse {
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60

        let body: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 1000,
            "system": prompt,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "image",
                            "source": [
                                "type": "base64",
                                "media_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ],
                        [
                            "type": "text",
                            "text": "Generate a Facebook Marketplace listing for this item. Return only valid JSON."
                        ]
                    ] as [[String: Any]]
                ]
            ] as [[String: Any]]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await performRequest(request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.invalidResponse
        }

        if httpResponse.statusCode != 200 {
            if let errorBody = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorBody["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw ServiceError.apiError(message)
            }
            throw ServiceError.apiError("API returned status \(httpResponse.statusCode)")
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let first = content.first,
              let text = first["text"] as? String else {
            throw ServiceError.invalidResponse
        }

        return try parseListingJSON(from: text)
    }

    // MARK: - Helpers

    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await URLSession.shared.data(for: request)
        } catch let error as URLError where error.code == .notConnectedToInternet || error.code == .networkConnectionLost {
            throw ServiceError.noInternet
        }
    }

    private func parseListingJSON(from text: String) throws -> ListingResponse {
        var jsonString = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // Strip markdown code fences if present
        if let range = jsonString.range(of: "```json") {
            jsonString = String(jsonString[range.upperBound...])
            if let endRange = jsonString.range(of: "```") {
                jsonString = String(jsonString[..<endRange.lowerBound])
            }
        } else if let range = jsonString.range(of: "```") {
            jsonString = String(jsonString[range.upperBound...])
            if let endRange = jsonString.range(of: "```") {
                jsonString = String(jsonString[..<endRange.lowerBound])
            }
        }

        // Extract the JSON object
        if let start = jsonString.firstIndex(of: "{"),
           let end = jsonString.lastIndex(of: "}") {
            jsonString = String(jsonString[start...end])
        }

        guard let data = jsonString.data(using: .utf8) else {
            throw ServiceError.invalidResponse
        }

        do {
            return try JSONDecoder().decode(ListingResponse.self, from: data)
        } catch {
            throw ServiceError.invalidResponse
        }
    }

    private func buildPrompt(
        category: ListingCategory?,
        sellingStyle: SellingStyle,
        pricingStrategy: PricingStrategy,
        conditionDetail: ConditionDetail,
        logistics: Set<LogisticsOption>
    ) -> String {
        let categoryText = category?.rawValue ?? "auto-detect"
        let logisticsText = logistics.isEmpty
            ? "not specified"
            : logistics.map { "\($0.icon) \($0.rawValue)" }.joined(separator: ", ")

        return """
        You are a Facebook Marketplace listing generator. Analyze the provided photo and generate a listing.

        Return a JSON object with exactly these keys:
        - "title": A compelling marketplace title (under 100 characters)
        - "price": Suggested price as an integer in USD
        - "description": A seller description (150-300 words)

        User preferences:
        - Category: \(categoryText)
        - Selling style: \(sellingStyle.rawValue) = \(sellingStyle.promptDescription)
        - Pricing strategy: \(pricingStrategy.rawValue) = \(pricingStrategy.promptDescription)
        - Condition detail: \(conditionDetail.rawValue) = \(conditionDetail.promptDescription)
        - Logistics: \(logisticsText)

        Format the description with bullet points for key features. Match the tone to the selling style selected. End with logistics info.

        Return ONLY the JSON object, no other text.
        """
    }
}
