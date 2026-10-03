func llmBuildServerAvailabilityReq(
    _ host: String,
    _ port: Int
) -> NetRequest {
    var req = NetRequest()
    req.headers = ["Accept": "application/json"]
    req.method = "GET"
    req.url = "http://\(host):\(port)/api/tags"

    return req
}
