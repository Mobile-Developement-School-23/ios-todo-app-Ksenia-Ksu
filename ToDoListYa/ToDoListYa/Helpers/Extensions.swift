import Foundation

extension Double {
    func timeInSecondsToDateString() -> String {
        let date = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        dateFormatter.timeZone = .current
        let localDate = dateFormatter.string(from: date)
        return localDate
    }
}

extension String {
    func stringToDoubleDate() -> Double {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        guard let date = dateFormatter.date(from: self) else { return 0 }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let data = calendar.date(from:components)
        let finalDate = Double(data?.timeIntervalSince1970 ?? 0)
        return finalDate
    }
    
}

extension Date {
    func stringFromDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        let date = dateFormatter.string(from: self)
        return date
    }
}
