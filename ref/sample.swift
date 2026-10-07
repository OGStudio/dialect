SWIFT-1
        c.recentField == F.didClickIncrement &&
        c.count == 9
SWIFT-2
        c.count += 10
SWIFT-3
        c.recentField == F.didClickIncrement
SWIFT-4
        c.count += 1
SWIFT-5
        c.recentField == F.count
SWIFT-6
        c.countText = "Count: '\(c.count)'"
SWIFT-7
        c.recentField == F.didLaunch
SWIFT-8
        c.countText = "Press the button to count"
SWIFT-9
        c.recentField == F.didSetup &&
        c.didLaunch == false
SWIFT-10
        c.didLaunch = true
SWIFT-11
        print(c.countText)
SWIFT-12
        RootVM.shared!.countText = c.countText
