import Foundation

func netLoad(
    _ req: NetRequest,
    _ reportSuccess: @escaping (NetResponse) -> Void,
    _ reportError: @escaping (NetResponse) -> Void
) {
    var res = NetResponse()
    res.req = req

    guard let url = URL(string: req.url) else {
        res.contents = NET_INVALID_URL
        reportError(res)

        return
    }

    var r = URLRequest(url: url)
    r.httpMethod = req.method
    r.httpBody = req.body.isEmpty ? nil : req.body.data(using: .utf8)
    for (key, value) in req.headers {
        r.setValue(value, forHTTPHeaderField: key)
    }

    let session = URLSession(configuration: .ephemeral)
    session.dataTask(with: r) { data, response, error in
        if let error = error {
            res.contents = "\(error)"
            reportError(res)
        } else if let http = response as? HTTPURLResponse,
            !(200 ..< 300).contains(http.statusCode) {
            let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            res.contents = "\(http.statusCode) \(body)"
            reportError(res)
        } else if let data = data {
            res.contents = String(data: data, encoding: .utf8) ?? ""
            reportSuccess(res)
        }
    }.resume()
}
