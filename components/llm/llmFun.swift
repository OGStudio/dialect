import Foundation

func llmBody(_ prompt: String) -> String {
    let payload: [String: Any] = [
        "model": LLM_DEFAULT_MODEL,
        "options": [
            "seed": LLM_SEED,
            "temperature": LLM_TEMPERATURE,
            "top_k": LLM_TOP_K
        ],
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
            return llmUnescape(String(ln.dropFirst(LLM_REPLY_PREFIX.count)))
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

func llmUnescape(_ str: String) -> String {
    var out = String()
    var idx = str.startIndex

    while idx < str.endIndex {
        let ch = str[idx]
        let nextIdx = str.index(after: idx)

        guard ch == "\\", nextIdx < str.endIndex else {
            out.append(ch)
            idx = nextIdx
            continue
        }

        let esc = str[nextIdx]
        let afterEsc = str.index(after: nextIdx)

        switch esc {
        case "\"":
            out.append("\"")
        case "\\":
            out.append("\\")
        case "/":
            out.append("/")
        case "b":
            out.append("\u{08}")
        case "f":
            out.append("\u{0C}")
        case "n":
            out.append("\n")
        case "r":
            out.append("\r")
        case "t":
            out.append("\t")
        case "u":
            guard str.distance(from: afterEsc, to: str.endIndex) >= 4 else {
                out.append(ch)
                out.append(esc)
                idx = afterEsc
                continue
            }
            let hexEnd = str.index(afterEsc, offsetBy: 4)
            let hex = String(str[afterEsc ..< hexEnd])
            guard var code = UInt32(hex, radix: 16) else {
                out.append(ch)
                out.append(esc)
                idx = afterEsc
                continue
            }
            idx = hexEnd
            if (0xD800 ... 0xDFFF).contains(code),
                str.distance(from: idx, to: str.endIndex) >= 6,
                str[idx] == "\\", str[str.index(after: idx)] == "u"
            {
                let lowStart = str.index(idx, offsetBy: 2)
                let lowEnd = str.index(lowStart, offsetBy: 4)
                if let low = UInt32(String(str[lowStart ..< lowEnd]), radix: 16),
                    (0xDC00 ... 0xDFFF).contains(low)
                {
                    code = 0x10000 + ((code - 0xD800) << 10) + (low - 0xDC00)
                    idx = lowEnd
                }
            }
            if let scalar = Unicode.Scalar(code) {
                out.append(Character(scalar))
            } else {
                out.append(contentsOf: "\\u" + hex)
            }
            continue
        default:
            out.append(ch)
            out.append(esc)
            idx = afterEsc
            continue
        }

        idx = afterEsc
    }

    return out
}
