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

// Extract "reponse" out of JSON
func llmExtractReply(_ json: String) -> String {
    let lines = json.components(separatedBy: LLM_LINE_DELIMITER)

    for ln in lines {
        if ln.hasPrefix(LLM_REPLY_PREFIX) {
            return String(ln.dropFirst(LLM_REPLY_PREFIX.count))
        }
    }

    return "ERROR Could not parse response"
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
