/// Register several oneliner callbacks to a controller
func registerOneliners(
    _ ctrl: DialectController,
    _ items: [Any]
) {
    let halfCount = items.count / 2
    for i in 0..<halfCount {
        let field = items[i * 2] as! String
        let callback = items[i * 2 + 1] as! (DialectContext) -> Void
        ctrl.registerFieldCallback(field, callback)
    }
}
