import Foundation

/// Kick off a request for any URL and push what comes back into the context,
/// or the reason it failed into the error field. Does not block: the push
/// happens later, on the main queue.
func llmLoad(
    _ req: NetRequest,
    _ keyResponse: String,
    _ keyResponseError: String
) {
    var res = NetResponse()
    res.req = req

    guard let url = URL(string: req.url) else {
        res.contents = LLM_INVALID_URL
        llmSet(keyResponseError, res)

        return
    }

    var r = URLRequest(url: url)
    r.httpMethod = req.method
    r.httpBody = req.body.isEmpty ? nil : req.body.data(using: .utf8)
    for (key, value) in req.headers {
        r.setValue(value, forHTTPHeaderField: key)
    }

    let session = URLSession(configuration: .ephemeral)
    session.dataTask(with: r) { data, _, error in
        if let error = error {
            res.contents = "\(error)"
            llmSetAsync(keyResponseError, res)
        } else if let data = data {
            res.contents = String(data: data, encoding: .utf8) ?? ""
            llmSetAsync(keyResponse, res)
        }
    }.resume()
}
