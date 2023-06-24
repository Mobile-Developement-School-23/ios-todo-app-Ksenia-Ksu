import UIKit

enum CSVText {
    static let headers = "ID,Task description,Task priority,Is done,DeadLine,Task start,Task was edited\n"
}

enum SFSymbols {
    static let checkmarkCircle = "checkmark.circle"
    static let circle = "circle"
    static let exclamationmarks = "exclamationmark.2"
    static let arrowDown = "arrow.down"
    static let calendar = "calendar"
    static let chevron = "chevron.right"
}

enum ThemeColors {
    static let backPrimary = UIColor(named: "BackPrimary")
    static let backSecondary = UIColor(named: "BackSecondary")
    static let backSegmentedControl = UIColor(named: "BackSegmentedControl")
    static let textViewColor = UIColor(named: "TextViewColor")
    static let separatorColor = UIColor(named: "DividerColor")
    static let placeholderColor = UIColor(named: "TextViewPlaceholderText")
}
