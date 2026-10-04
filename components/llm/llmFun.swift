import Foundation

/// JSON-encode the payload rather than interpolating into a string literal, so
/// a prompt containing a quote, backslash or newline cannot break the request
func llmBody(_ prompt: String) -> String {
    let payload: [String: Any] = [
        "model": LLM_DEFAULT_MODEL, "prompt": prompt, "stream": false
    ]
    guard let data = try? JSONSerialization.data(withJSONObject: payload) else {
        return ""
    }

    return String(data: data, encoding: .utf8) ?? ""
}

func llmBuildReqPrompt(
    _ host: String,
    _ port: Int,
    _ prompt: String
) -> NetRequest {
    var req = NetRequest()
    req.headers = [LLM_ACCEPT: LLM_APP_JSON, LLM_CONTENT_TYPE: LLM_APP_JSON]
    req.method = LLM_POST
    req.url = LLM_URL_GENERATE_T
        .replacingOccurrences(of: "%HOST%", with: host)
        .replacingOccurrences(of: "%PORT%", with: "\(port)")
    req.body = llmBody(prompt)

    return req
}
