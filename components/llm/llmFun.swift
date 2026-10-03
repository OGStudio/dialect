func llmBuildServerAvailabilityReq(
    _ host: String,
    _ port: Int
) -> NetRequest {
    var req = NetRequest()
    req.headers = [LLM_ACCEPT: LLM_APP_JSON]
    req.method = LLM_GET
    req.url = "http://\(host):\(port)/api/tags"

    return req
}
