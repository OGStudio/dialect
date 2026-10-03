import Foundation

/// Perform a blocking request and tell whether the server answered
func llmIsReachable(_ req: NetRequest) -> Bool {
    guard let url = URL(string: req.url) else {
        return false
    }

    var urlReq = URLRequest(url: url)
    urlReq.httpMethod = req.method
    urlReq.httpBody = req.body.isEmpty
        ? nil
        : req.body.data(using: .utf8)
    for (key, value) in req.headers.sorted(by: { $0.key < $1.key }) {
        urlReq.setValue(value, forHTTPHeaderField: key)
    }

    let semaphore = DispatchSemaphore(value: 0)
    let session = URLSession(configuration: .ephemeral)
    var isOk = false
    session.dataTask(with: urlReq) { _, response, _ in
        if let http = response as? HTTPURLResponse {
            isOk = (200 ..< 300).contains(http.statusCode)
        }
        semaphore.signal()
    }.resume()

    _ = semaphore.wait(timeout: .now() + LLM_DEFAULT_TIMEOUT)

    return isOk
}
