import Foundation

func llmBody(_ prompt: String) -> String {
    let payload: [String: Any] = [
        "model": LLM_DEFAULT_MODEL,
        "prompt": prompt,
        "stream": false
    ]

    guard
        let data = try? JSONSerialization.data(withJSONObject: payload)
    else {
        return ""
    }

    return String(data: data, encoding: .utf8) ?? ""
}

/// Pull the answer text out of the Ollama envelope by hand: drop the enclosing
/// braces and the opening quote, then split on `","`, which is the boundary
/// BETWEEN keys and so never appears inside a value — a reply holding a comma
/// (`Hello, world!`) survives whole, unlike a plain `,` split. Each segment then
/// reads `<key>":<value>`, so the answer is the one opening with the response
/// key, with the surrounding quotes trimmed off.
func llmFormatResponse(_ contents: String) -> String {
    var body = contents
    if body.hasPrefix("{") {
        body = String(body.dropFirst())
    }
    if body.hasSuffix("}") {
        body = String(body.dropLast())
    }
    if body.hasPrefix("\"") {
        body = String(body.dropFirst())
    }

    let prefix = LLM_RESPONSE_PREFIX + "\":"

    for part in body.components(separatedBy: "\",\"") {
        if part.hasPrefix(prefix) {
            var value = String(part.dropFirst(prefix.count))
            if value.hasPrefix("\"") {
                value = String(value.dropFirst())
            }
            if value.hasSuffix("\"") {
                value = String(value.dropLast())
            }

            return value
        }
    }

    return ""
}

func llmReqPrompt(
    _ host: String,
    _ port: Int,
    _ prompt: String
) -> NetRequest {
    var req = NetRequest()
    req.headers = [NET_CONTENT_TYPE: NET_APP_JSON]
    req.method = NET_POST
    req.url = LLM_URL_GENERATE_T
        .replacingOccurrences(of: "%HOST%", with: host)
        .replacingOccurrences(of: "%PORT%", with: "\(port)")
    req.body = llmBody(prompt)

    return req
}
