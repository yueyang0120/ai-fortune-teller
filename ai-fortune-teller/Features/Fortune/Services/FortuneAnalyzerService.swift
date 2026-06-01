import Foundation

enum FortuneAnalyzerError: Error, LocalizedError {
    case invalidAPIKey
    case networkError(Error)
    case invalidResponse
    case apiError(String)
    case decodingError
    case allAPIsFailed([String])

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "API Key 未配置"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .invalidResponse:
            return "API 返回的数据格式无效"
        case .apiError(let message):
            return "API 错误: \(message)"
        case .decodingError:
            return "解析响应数据失败"
        case .allAPIsFailed(let errors):
            return "所有 API 均失败:\n" + errors.joined(separator: "\n")
        }
    }
}

class FortuneAnalyzerService {
    private let geminiAPIKey: String
    private let geminiModel: String
    private let geminiEndpoint: String

    private let openAIAPIKey: String
    private let openAIModel: String
    private let openAIEndpoint: String
    private let openAIReasoningEffort: String

    private let deepSeekAPIKey: String
    private let deepSeekModel: String
    private let deepSeekEndpoint: String

    // RAG Configuration
    private let fileSearchStoreName: String
    private let isRAGEnabled: Bool

    init() {
        self.geminiAPIKey = BackendConfig.geminiAPIKey
        self.geminiModel = BackendConfig.geminiModel
        self.geminiEndpoint = BackendConfig.geminiEndpoint

        self.openAIAPIKey = BackendConfig.openAIAPIKey
        self.openAIModel = BackendConfig.openAIModel
        self.openAIEndpoint = BackendConfig.openAIEndpoint
        self.openAIReasoningEffort = BackendConfig.openAIReasoningEffort

        self.deepSeekAPIKey = BackendConfig.deepSeekAPIKey
        self.deepSeekModel = BackendConfig.deepSeekModel
        self.deepSeekEndpoint = BackendConfig.deepSeekEndpoint

        // RAG Configuration
        self.fileSearchStoreName = BackendConfig.fileSearchStoreName
        self.isRAGEnabled = BackendConfig.isRAGEnabled

        // Debug: 打印 RAG 配置状态
        print("🔧 FortuneAnalyzerService initialized:")
        print("   RAG Enabled: \(self.isRAGEnabled)")
        print("   Store Name: \(self.fileSearchStoreName)")
        print("   Gemini Model: \(self.geminiModel)")
    }

    // 重试配置
    private let maxRetries = 2
    private let retryDelay: UInt64 = 3_000_000_000 // 3秒（纳秒）

    func analyze(chart: ZiWeiChart, birthInfo: BirthInfo, yearlyFlows: [YearlyFlowContext]? = nil) async throws -> String {
        // 使用分离格式的 prompt（systemInstruction + userContent），更利于 RAG
        let separatedPrompt = DetailedPromptGenerator.generateSeparatedPrompt(chart: chart, birthInfo: birthInfo, yearlyFlows: yearlyFlows)

        // 合并版本用于非 Gemini API
        let combinedPrompt = separatedPrompt.systemInstruction + separatedPrompt.userContent

        // Debug: 输出 prompt 信息
        print("📝 ========== PROMPT INFO ==========")
        print("📝 System Instruction length: \(separatedPrompt.systemInstruction.count) characters")
        print("📝 User Content length: \(separatedPrompt.userContent.count) characters")
        print("📝 Total length: \(combinedPrompt.count) characters")
        print("📝 ========== FULL USER PROMPT START ==========")
        print(separatedPrompt.userContent)
        print("📝 ========== FULL USER PROMPT END ==========")
        print("📝 ==================================")

        var errors: [String] = []

        // 按顺序尝试：Gemini -> DeepSeek -> OpenAI
        // 每个模型重试 2 次

        // 1. 尝试 Gemini
        if !geminiAPIKey.isEmpty && geminiAPIKey != "YOUR_GEMINI_API_KEY_HERE" {
            print("🤖 Trying Gemini...")
            for attempt in 1...maxRetries {
                do {
                    print("🤖 Gemini attempt \(attempt)/\(maxRetries)...")
                    let result = try await analyzeWithGemini(separatedPrompt: separatedPrompt)
                    print("✅ Gemini analysis completed successfully")
                    return result
                } catch {
                    print("❌ Gemini attempt \(attempt) failed: \(error.localizedDescription)")
                    if attempt < maxRetries {
                        print("⏳ Waiting 3 seconds before retry...")
                        try? await Task.sleep(nanoseconds: retryDelay)
                    } else {
                        errors.append("Gemini 失败 (重试\(maxRetries)次): \(error.localizedDescription)")
                    }
                }
            }
        } else {
            print("⚠️ Gemini API Key 未配置，跳过")
        }

        // 2. 尝试 DeepSeek
        if !deepSeekAPIKey.isEmpty {
            print("🔄 Falling back to DeepSeek...")
            for attempt in 1...maxRetries {
                do {
                    print("🤖 DeepSeek attempt \(attempt)/\(maxRetries)...")
                    let result = try await analyzeWithDeepSeek(prompt: combinedPrompt)
                    print("✅ DeepSeek analysis completed successfully")
                    return result
                } catch {
                    print("❌ DeepSeek attempt \(attempt) failed: \(error.localizedDescription)")
                    if attempt < maxRetries {
                        print("⏳ Waiting 3 seconds before retry...")
                        try? await Task.sleep(nanoseconds: retryDelay)
                    } else {
                        errors.append("DeepSeek 失败 (重试\(maxRetries)次): \(error.localizedDescription)")
                    }
                }
            }
        } else {
            print("⚠️ DeepSeek API Key 未配置，跳过")
        }

        // 3. 尝试 OpenAI
        if !openAIAPIKey.isEmpty && openAIAPIKey != "YOUR_OPENAI_API_KEY_HERE" {
            print("🔄 Falling back to OpenAI...")
            for attempt in 1...maxRetries {
                do {
                    print("🤖 OpenAI attempt \(attempt)/\(maxRetries)...")
                    let result = try await analyzeWithOpenAI(prompt: combinedPrompt)
                    print("✅ OpenAI analysis completed successfully")
                    return result
                } catch {
                    print("❌ OpenAI attempt \(attempt) failed: \(error.localizedDescription)")
                    if attempt < maxRetries {
                        print("⏳ Waiting 3 seconds before retry...")
                        try? await Task.sleep(nanoseconds: retryDelay)
                    } else {
                        errors.append("OpenAI 失败 (重试\(maxRetries)次): \(error.localizedDescription)")
                    }
                }
            }
        } else {
            print("⚠️ OpenAI API Key 未配置，跳过")
        }

        // 所有 API 都失败了
        throw FortuneAnalyzerError.allAPIsFailed(errors)
    }

    // MARK: - DeepSeek API

    private func analyzeWithDeepSeek(prompt: String) async throws -> String {
        let request = try buildDeepSeekAPIRequest(prompt: prompt)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw FortuneAnalyzerError.invalidResponse
        }

        print("📡 DeepSeek API Response Status: \(httpResponse.statusCode)")

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ DeepSeek API Error: \(errorMessage)")
            throw FortuneAnalyzerError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }

        return try parseDeepSeekAPIResponse(data: data)
    }

    private func buildDeepSeekAPIRequest(prompt: String) throws -> URLRequest {
        guard let url = URL(string: deepSeekEndpoint) else {
            throw FortuneAnalyzerError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(deepSeekAPIKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 300

        let requestBody: [String: Any] = [
            "model": deepSeekModel,
            "messages": [
                ["role": "system", "content": "你是一位精通紫微斗数的算命大师。请根据用户的命盘数据进行详细分析。"],
                ["role": "user", "content": prompt]
            ],
            "stream": false
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        return request
    }

    private func parseDeepSeekAPIResponse(data: Data) throws -> String {
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

            if let error = json?["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw FortuneAnalyzerError.apiError(message)
            }

            if let choices = json?["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any] {

                if let reasoning = message["reasoning_content"] as? String {
                    // If using deepseek-reasoner, we might want to include or log the reasoning
                    print("🤔 DeepSeek Reasoning: \(reasoning.prefix(100))...")
                }

                if let content = message["content"] as? String {
                    return content
                }
            }

            throw FortuneAnalyzerError.decodingError
        } catch {
            print("❌ DeepSeek decoding error: \(error)")
            throw FortuneAnalyzerError.decodingError
        }
    }

    // MARK: - Gemini API

    private func analyzeWithGemini(separatedPrompt: DetailedPromptGenerator.SeparatedPrompt) async throws -> String {
        let request = try buildGeminiAPIRequest(separatedPrompt: separatedPrompt)

        // 发送请求
        let (data, response) = try await URLSession.shared.data(for: request)

        // 检查 HTTP 状态
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FortuneAnalyzerError.invalidResponse
        }

        print("📡 Gemini API Response Status: \(httpResponse.statusCode)")

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ Gemini API Error: \(errorMessage)")
            throw FortuneAnalyzerError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }

        // 解析响应
        let analysisText = try parseGeminiAPIResponse(data: data)

        print("✅ Gemini analysis completed, length: \(analysisText.count) characters")

        return analysisText
    }

    private func buildGeminiAPIRequest(separatedPrompt: DetailedPromptGenerator.SeparatedPrompt) throws -> URLRequest {
        let urlString = "\(geminiEndpoint)/\(geminiModel):generateContent"

        guard let url = URL(string: urlString) else {
            throw FortuneAnalyzerError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(geminiAPIKey, forHTTPHeaderField: "x-goog-api-key")
        request.timeoutInterval = 300 // Gemini thinking 模型可能需要更长时间（5分钟）

        // 构建 Gemini API 请求体 - 使用 systemInstruction 分离系统指令
        var requestBody: [String: Any] = [
            // 系统指令（角色设定、分析指南等）
            "systemInstruction": [
                "parts": [
                    ["text": separatedPrompt.systemInstruction]
                ]
            ],
            // 用户内容（命盘数据 + 分析要求）
            "contents": [
                [
                    "parts": [
                        ["text": separatedPrompt.userContent]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 1.0,
                "maxOutputTokens": 18000
            ]
        ]

        // 🔍 RAG: 添加 File Search 工具（紫微斗数知识库）
        if isRAGEnabled && !fileSearchStoreName.isEmpty {
            print("📚 RAG enabled: Using knowledge base \(fileSearchStoreName)")
            print("📚 RAG store name format check: \(fileSearchStoreName.hasPrefix("fileSearchStores/") ? "✅ Valid" : "⚠️ Missing prefix")")
            requestBody["tools"] = [
                [
                    "file_search": [
                        "file_search_store_names": [fileSearchStoreName]
                    ]
                ]
            ]
        }

        // Debug: 打印请求体关键部分
        print("📤 Gemini Request Body Info:")
        print("   System Instruction length: \(separatedPrompt.systemInstruction.count) characters")
        print("   User Content length: \(separatedPrompt.userContent.count) characters")
        print("   Using systemInstruction: ✅ (separated format for better RAG)")

        // 专门打印 tools 配置
        if let tools = requestBody["tools"] {
            if let toolsData = try? JSONSerialization.data(withJSONObject: tools, options: .prettyPrinted),
               let toolsString = String(data: toolsData, encoding: .utf8) {
                print("   🔧 Tools config:")
                print(toolsString)
            }
        } else {
            print("   ⚠️ No tools in request body!")
        }

        // 🔍 DEBUG: 打印完整请求体结构（不含内容，只看结构）
        print("📝 Request body keys: \(requestBody.keys.sorted().joined(separator: ", "))")

        let httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = httpBody

        // 打印请求体的前 500 字符来验证格式
        if let bodyString = String(data: httpBody, encoding: .utf8) {
            print("📝 Request body preview (first 500 chars):")
            print(String(bodyString.prefix(500)))
        }

        return request
    }

    private func parseGeminiAPIResponse(data: Data) throws -> String {
        do {
            // 🔍 DEBUG: 先打印原始响应（前 2000 字符）
            if let rawString = String(data: data, encoding: .utf8) {
                print("📦 ========== RAW RESPONSE START ==========")
                print(String(rawString.suffix(2000)))  // 打印最后 2000 字符，因为 grounding 在末尾
                print("📦 ========== RAW RESPONSE END ==========")
            }

            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

            // 🔍 Debug: 打印响应的顶层 keys
            if let keys = json?.keys {
                print("📡 Gemini Response keys: \(keys.joined(separator: ", "))")
            }

            // Debug: 打印第一个 candidate 的所有内容（用于调试 grounding）
            if let candidates = json?["candidates"] as? [[String: Any]],
               let firstCandidate = candidates.first {
                print("📋 First candidate raw keys: \(firstCandidate.keys.sorted().joined(separator: ", "))")

                // 尝试直接从原始数据中搜索 grounding 关键字
                if let rawString = String(data: data, encoding: .utf8) {
                    if rawString.contains("groundingMetadata") {
                        print("✅ 'groundingMetadata' found in raw response!")
                    } else if rawString.contains("grounding") {
                        print("⚠️ 'grounding' found but not 'groundingMetadata'")
                    } else {
                        print("❌ No grounding-related content in response")
                    }
                }
            }

            // 检查错误
            if let error = json?["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw FortuneAnalyzerError.apiError(message)
            }

            // 解析 Gemini API 响应格式
            // Response: { "candidates": [{ "content": { "parts": [{ "text": "..." }] }, "groundingMetadata": {...} }] }
            if let candidates = json?["candidates"] as? [[String: Any]],
               let firstCandidate = candidates.first,
               let content = firstCandidate["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let firstPart = parts.first,
               let text = firstPart["text"] as? String {

                // 📚 RAG: 解析 grounding metadata（知识库引用信息）
                // 检查 camelCase 和 snake_case 两种格式
                if let groundingMetadata = firstCandidate["groundingMetadata"] as? [String: Any] {
                    parseGroundingMetadata(groundingMetadata)
                } else if let groundingMetadata = firstCandidate["grounding_metadata"] as? [String: Any] {
                    // Google API 有时使用 snake_case
                    parseGroundingMetadata(groundingMetadata)
                } else {
                    // 检查是否有 grounding 相关的其他字段
                    print("📚 RAG grounding metadata 未返回")
                    print("   Candidate keys: \(firstCandidate.keys.joined(separator: ", "))")

                    // 检查各种可能的 grounding 字段
                    if let groundingChunks = firstCandidate["groundingChunks"] ?? firstCandidate["grounding_chunks"] {
                        print("   发现 groundingChunks: \(groundingChunks)")
                    }
                    if let citationMetadata = firstCandidate["citationMetadata"] ?? firstCandidate["citation_metadata"] {
                        print("   发现 citationMetadata: \(citationMetadata)")
                    }

                    // 如果 RAG 启用但没有返回 grounding，可能是 store 问题
                    if self.isRAGEnabled {
                        print("   ⚠️ RAG 已启用但未返回 grounding 数据，请检查:")
                        print("      1. FileSearchStore 是否存在: \(self.fileSearchStoreName)")
                        print("      2. Store 中是否有文档")
                        print("      3. 文档是否已完成索引")
                    }
                }

                return text
            }

            throw FortuneAnalyzerError.decodingError

        } catch let error as FortuneAnalyzerError {
            throw error
        } catch {
            print("❌ Gemini decoding error: \(error)")
            throw FortuneAnalyzerError.decodingError
        }
    }

    /// 解析 RAG grounding metadata，记录引用的知识库来源
    private func parseGroundingMetadata(_ metadata: [String: Any]) {
        print("📚 ========== RAG GROUNDING INFO ==========")

        // 解析引用的文档片段
        if let groundingChunks = metadata["groundingChunks"] as? [[String: Any]] {
            print("📖 引用了 \(groundingChunks.count) 个知识库片段:")
            for (index, chunk) in groundingChunks.enumerated() {
                print("")
                print("   📄 Chunk \(index + 1):")
                if let retrievedContext = chunk["retrievedContext"] as? [String: Any] {
                    // 打印 Store 来源
                    if let store = retrievedContext["fileSearchStore"] as? String {
                        print("      Store: \(store)")
                    }
                    // 打印 URI (如果有)
                    if let uri = retrievedContext["uri"] as? String {
                        print("      URI: \(uri)")
                    }
                    // 打印标题 (如果有)
                    if let title = retrievedContext["title"] as? String {
                        print("      Title: \(title)")
                    }
                    // 打印文本内容 (完整打印用于 Eval)
                    if let text = retrievedContext["text"] as? String {
                        print("      ----- RETRIEVED CONTENT START -----")
                        print(text)
                        print("      ----- RETRIEVED CONTENT END -----")
                    }
                } else {
                    print("      ⚠️ No retrievedContext in chunk")
                    print("      Chunk keys: \(chunk.keys.joined(separator: ", "))")
                }
            }
        } else {
            print("❌ No groundingChunks found")
            print("   Metadata keys: \(metadata.keys.joined(separator: ", "))")
        }

        // 解析支持信息
        if let groundingSupports = metadata["groundingSupports"] as? [[String: Any]] {
            print("")
            print("🔗 共有 \(groundingSupports.count) 处引用支持")
            // 打印所有支持信息用于 Eval
            for (index, support) in groundingSupports.enumerated() {
                if let segment = support["segment"] as? [String: Any],
                   let text = segment["text"] as? String {
                    let chunkIndices = support["groundingChunkIndices"] as? [Int] ?? []
                    print("   \(index + 1). \"\(text)\" → Chunks: \(chunkIndices)")
                }
            }
        }

        // 解析检索元数据
        if let retrievalMetadata = metadata["retrievalMetadata"] as? [String: Any] {
            if let googleSearchDynamicRetrievalScore = retrievalMetadata["googleSearchDynamicRetrievalScore"] as? Double {
                print("🔍 检索相关性分数: \(String(format: "%.2f", googleSearchDynamicRetrievalScore))")
            }
        }

        print("")
        print("📚 ========== END RAG INFO ==========")
    }

    // MARK: - OpenAI API

    private func analyzeWithOpenAI(prompt: String) async throws -> String {
        let request = try buildOpenAIAPIRequest(prompt: prompt)

        // 发送请求
        let (data, response) = try await URLSession.shared.data(for: request)

        // 检查 HTTP 状态
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FortuneAnalyzerError.invalidResponse
        }

        print("📡 OpenAI API Response Status: \(httpResponse.statusCode)")

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ OpenAI API Error: \(errorMessage)")
            throw FortuneAnalyzerError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }

        // 解析响应
        let analysisText = try parseOpenAIAPIResponse(data: data)

        print("✅ OpenAI analysis completed, length: \(analysisText.count) characters")

        return analysisText
    }

    private func buildOpenAIAPIRequest(prompt: String) throws -> URLRequest {
        guard let url = URL(string: openAIEndpoint) else {
            throw FortuneAnalyzerError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 300 // GPT-5.1 高推理需要更长时间（5分钟）

        // 构建 OpenAI GPT-5.1 API 请求体（新格式）
        let requestBody: [String: Any] = [
            "model": openAIModel,
            "input": prompt,
            "reasoning": [
                "effort": openAIReasoningEffort  // "high" for maximum thinking depth
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        return request
    }

    private func parseOpenAIAPIResponse(data: Data) throws -> String {
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

            // 检查错误
            if let error = json?["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw FortuneAnalyzerError.apiError(message)
            }

            // 解析 OpenAI GPT-5.1 响应格式 (新 /v1/responses endpoint)
            // Response: { "output": "..." } 或 { "choices": [{ "text": "..." }] }

            // 尝试新格式：直接从 output 字段获取
            if let output = json?["output"] as? String {
                return output
            }

            // 尝试 choices 格式（兼容性）
            if let choices = json?["choices"] as? [[String: Any]],
               let firstChoice = choices.first {

                // 尝试 text 字段
                if let text = firstChoice["text"] as? String {
                    return text
                }

                // 尝试 message.content 字段（旧格式兼容）
                if let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    return content
                }
            }

            throw FortuneAnalyzerError.decodingError

        } catch let error as FortuneAnalyzerError {
            throw error
        } catch {
            print("❌ OpenAI decoding error: \(error)")
            throw FortuneAnalyzerError.decodingError
        }
    }

    // MARK: - Synastry Analysis

    func analyzeSynastry(synastryInfo: SynastryInfo) async throws -> String {
        guard let chartA = synastryInfo.chartA, let chartB = synastryInfo.chartB else {
            throw FortuneAnalyzerError.invalidResponse
        }

        let separatedPrompt = DetailedPromptGenerator.generateSynastryPrompt(
            chartA: chartA, birthInfoA: synastryInfo.personA,
            chartB: chartB, birthInfoB: synastryInfo.personB,
            synastryType: synastryInfo.synastryType,
            relationshipRole: synastryInfo.relationshipRole
        )

        let combinedPrompt = separatedPrompt.systemInstruction + separatedPrompt.userContent

        print("📝 ========== SYNASTRY PROMPT INFO ==========")
        print("📝 Synastry type: \(synastryInfo.synastryType.rawValue)")
        print("📝 Total length: \(combinedPrompt.count) characters")
        print("📝 ============================================")

        var errors: [String] = []

        // Gemini
        if !geminiAPIKey.isEmpty && geminiAPIKey != "YOUR_GEMINI_API_KEY_HERE" {
            print("🤖 Trying Gemini for synastry...")
            for attempt in 1...maxRetries {
                do {
                    let result = try await analyzeWithGemini(separatedPrompt: separatedPrompt)
                    print("✅ Gemini synastry analysis completed")
                    return result
                } catch {
                    print("❌ Gemini synastry attempt \(attempt) failed: \(error.localizedDescription)")
                    if attempt < maxRetries {
                        try? await Task.sleep(nanoseconds: retryDelay)
                    } else {
                        errors.append("Gemini 失败: \(error.localizedDescription)")
                    }
                }
            }
        }

        // DeepSeek
        if !deepSeekAPIKey.isEmpty {
            print("🔄 Falling back to DeepSeek for synastry...")
            for attempt in 1...maxRetries {
                do {
                    let result = try await analyzeWithDeepSeek(prompt: combinedPrompt)
                    print("✅ DeepSeek synastry analysis completed")
                    return result
                } catch {
                    print("❌ DeepSeek synastry attempt \(attempt) failed: \(error.localizedDescription)")
                    if attempt < maxRetries {
                        try? await Task.sleep(nanoseconds: retryDelay)
                    } else {
                        errors.append("DeepSeek 失败: \(error.localizedDescription)")
                    }
                }
            }
        }

        // OpenAI
        if !openAIAPIKey.isEmpty && openAIAPIKey != "YOUR_OPENAI_API_KEY_HERE" {
            print("🔄 Falling back to OpenAI for synastry...")
            for attempt in 1...maxRetries {
                do {
                    let result = try await analyzeWithOpenAI(prompt: combinedPrompt)
                    print("✅ OpenAI synastry analysis completed")
                    return result
                } catch {
                    print("❌ OpenAI synastry attempt \(attempt) failed: \(error.localizedDescription)")
                    if attempt < maxRetries {
                        try? await Task.sleep(nanoseconds: retryDelay)
                    } else {
                        errors.append("OpenAI 失败: \(error.localizedDescription)")
                    }
                }
            }
        }

        throw FortuneAnalyzerError.allAPIsFailed(errors)
    }
}
