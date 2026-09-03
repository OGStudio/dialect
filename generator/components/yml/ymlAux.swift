
func ymlPrintValue(_ value: Any, indent: Int = 0) {
    let pad = String(repeating: "_", count: indent)

    if let dict = value as? [String: Any] {
        for (k, v) in dict {
            if v is [String: Any] || v is [Any] {
                print("_1.1_\(pad)\(k):")
                ymlPrintValue(v, indent: indent + 1)
            } else {
                print("_1.2._\(pad)\(k): \(v)")
            }
        }
    } else if let arr = value as? [Any] {
        for item in arr {
            if let d = item as? [String: Any] {
                print("_2.1_\(pad)-")
                ymlPrintValue(d, indent: indent + 1)
            } else if let a = item as? [Any] {
                print("_2.2_\(pad)-")
                ymlPrintValue(a, indent: indent + 1)
            } else {
                print("_2.3_\(pad)- \(item)")
            }
        }
    } else {
        print("_3_\(pad)\(value)")
    }
}
