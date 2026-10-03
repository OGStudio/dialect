import Foundation

func llmBuildReqServerAvailability(
    _ host: String,
    _ port: Int
) -> NetRequest {
    var req = NetRequest()
    req.headers = [LLM_ACCEPT: LLM_APP_JSON]
    req.method = LLM_GET
    req.url = LLM_URL_AVAILABILITY_T
        .replacingOccurrences(of: "%HOST%", with: host)
        .replacingOccurrences(of: "%PORT%", with: "\(port)")

    return req
}
