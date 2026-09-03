
func ymlPrintValue(_ value: Any, indent: Int = 0) {
    let pad = String(repeating: "  ", count: indent)

    if let dict = value as? [String: Any] {
        for (k, v) in dict {
            if v is [String: Any] || v is [Any] {
                print("\(pad)\(k):")
                ymlPrintValue(v, indent: indent + 1)
            } else {
                print("\(pad)\(k): \(v)")
            }
        }
    } else if let arr = value as? [Any] {
        for item in arr {
            if let d = item as? [String: Any] {
                print("\(pad)-")
                ymlPrintValue(d, indent: indent + 1)
            } else if let a = item as? [Any] {
                print("\(pad)-")
                ymlPrintValue(a, indent: indent + 1)
            } else {
                print("\(pad)- \(item)")
            }
        }
    } else {
        print("\(pad)\(value)")
    }
}
