import Foundation

enum GeminiPodcastError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case noAudioData
    case httpStatus(Int, String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Missing Gemini API key. Add GEMINI_API_KEY to the app’s Info.plist."
        case .invalidResponse:
            return "Gemini returned an unexpected response."
        case .noAudioData:
            return "Gemini did not return audio data."
        case let .httpStatus(code, body):
            return "Gemini request failed (\(code)). \(body)"
        }
    }
}

struct GeminiPodcastService {
    var modelName: String = "gemini-3.1-flash-tts-preview"
    var voiceName: String = "Kore"

    func generatePodcastWav(text: String) async throws -> URL {
        // Try to read from Info.plist first, fall back to Config
        var apiKey = (Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if apiKey == nil || apiKey!.isEmpty {
            apiKey = Config.geminiAPIKey
        }
        
        guard let apiKey, !apiKey.isEmpty else {
            throw GeminiPodcastError.missingAPIKey
        }

        let endpoint = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(modelName):generateContent")!
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 60 // 60 seconds timeout for audio generation
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")

        let payload = GenerateContentRequest(
            contents: [
                .init(
                    role: "user",
                    parts: [
                        .init(text: "Say in a warm, engaging podcast-host style:\n\n\(text)")
                    ]
                )
            ],
            generationConfig: .init(
                responseModalities: ["AUDIO"],
                speechConfig: .init(
                    voiceConfig: .init(
                        prebuiltVoiceConfig: .init(voiceName: voiceName)
                    )
                )
            )
        )
        request.httpBody = try JSONEncoder().encode(payload)
        
        print("🎙️ Calling Gemini API: \(endpoint)")
        let (data, response) = try await URLSession.shared.data(for: request)
        print("🎙️ Received response from Gemini API")
        guard let http = response as? HTTPURLResponse else {
            throw GeminiPodcastError.invalidResponse
        }
        if !(200...299).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw GeminiPodcastError.httpStatus(http.statusCode, body)
        }

        let decoded = try JSONDecoder().decode(GenerateContentResponse.self, from: data)
        guard
            let base64 = decoded.candidates.first?.content.parts.first?.inlineData?.data,
            let pcmData = Data(base64Encoded: base64)
        else {
            throw GeminiPodcastError.noAudioData
        }

        let wavData = WAVWriter.wavData(fromPCM16LE: pcmData, sampleRate: 24_000, channels: 1)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("wordcast-podcast-\(UUID().uuidString).wav")
        try wavData.write(to: url, options: [.atomic])
        return url
    }
}

private struct GenerateContentRequest: Codable {
    struct Content: Codable {
        let role: String
        let parts: [Part]
    }

    struct Part: Codable {
        let text: String
    }

    struct GenerationConfig: Codable {
        let responseModalities: [String]
        let speechConfig: SpeechConfig
    }

    struct SpeechConfig: Codable {
        let voiceConfig: VoiceConfig
    }

    struct VoiceConfig: Codable {
        let prebuiltVoiceConfig: PrebuiltVoiceConfig
    }

    struct PrebuiltVoiceConfig: Codable {
        let voiceName: String
    }

    let contents: [Content]
    let generationConfig: GenerationConfig
}

private struct GenerateContentResponse: Codable {
    struct Candidate: Codable {
        let content: Content
    }

    struct Content: Codable {
        let parts: [Part]
    }

    struct Part: Codable {
        let inlineData: InlineData?
    }

    struct InlineData: Codable {
        let mimeType: String?
        let data: String?
    }

    let candidates: [Candidate]
}

private enum WAVWriter {
    static func wavData(fromPCM16LE pcm: Data, sampleRate: Int, channels: Int) -> Data {
        let bitsPerSample = 16
        let bytesPerSample = bitsPerSample / 8
        let byteRate = sampleRate * channels * bytesPerSample
        let blockAlign = UInt16(channels * bytesPerSample)

        var data = Data()
        data.append("RIFF".data(using: .ascii)!)
        data.append(UInt32(36 + pcm.count).littleEndianData)
        data.append("WAVE".data(using: .ascii)!)

        data.append("fmt ".data(using: .ascii)!)
        data.append(UInt32(16).littleEndianData)
        data.append(UInt16(1).littleEndianData)
        data.append(UInt16(channels).littleEndianData)
        data.append(UInt32(sampleRate).littleEndianData)
        data.append(UInt32(byteRate).littleEndianData)
        data.append(blockAlign.littleEndianData)
        data.append(UInt16(bitsPerSample).littleEndianData)

        data.append("data".data(using: .ascii)!)
        data.append(UInt32(pcm.count).littleEndianData)
        data.append(pcm)
        return data
    }
}

private extension FixedWidthInteger {
    var littleEndianData: Data {
        var value = self.littleEndian
        return Data(bytes: &value, count: MemoryLayout<Self>.size)
    }
}
