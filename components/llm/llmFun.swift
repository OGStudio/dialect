import Foundation

func llmBody(_ prompt: String) -> String {
    let payload: [String: Any] = [
        "model": LLM_DEFAULT_MODEL,
        "prompt": prompt,
        "stream": false
    ]
    guard
        let dat = try? JSONSerialization.data(withJSONObject: payload)
    else {
        return ""
    }

    return String(data: dat, encoding: .utf8) ?? ""
}

func llmReqPrompt(
    _ host: String,
    _ port: Int,
    _ prompt: String
) -> NetRequest {
    var req = NetRequest()
    req.headers = [LLM_CONTENT_TYPE: LLM_APP_JSON]
    req.method = LLM_POST
    req.url = LLM_URL_GENERATE_T
        .replacingOccurrences(of: "%HOST%", with: host)
        .replacingOccurrences(of: "%PORT%", with: "\(port)")
    req.body = llmBody(prompt)

    return req
}
