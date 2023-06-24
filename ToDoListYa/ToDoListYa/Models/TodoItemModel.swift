import Foundation

struct TodoItem: Equatable {
    let id: String
    let text: String
    let priority: String
    let taskDone: Bool
    
    let deadline: Double?
    let taskStartDate: Double
    let taskEditDate: Double?
    let hexColor: String?
    
    init( id: String = UUID().uuidString,
          text: String,
          priority: String = TaskPriority.ordinary.rawValue,
          taskDone: Bool = false,
          deadline: Double? = nil,
          taskStartDate: Double = Double(Date().timeIntervalSince1970),
          taskEditDate: Double? = nil,
          hexColor: String? = nil
    ) { self.id = id
        self.text = text
        self.priority = priority
        self.taskDone = taskDone
        self.deadline = deadline
        self.taskStartDate = taskStartDate
        self.taskEditDate = taskEditDate
        self.hexColor = hexColor
    }
    static let separator = ","
}

enum TaskPriority: String {
    case important = "important"
    case ordinary = "ordinary"
    case unimportant = "unimportant"
}

//MARK: - parsing JSON
extension TodoItem {
    
    var json: Any {
        var json: [String: Any] = [
            Keys.idKey: id,
            Keys.textKey: text,
            Keys.taskDoneKey: taskDone,
            Keys.taskStartDateKey: taskStartDate ]
        
        if priority != TaskPriority.ordinary.rawValue {
            json[Keys.priorityKey] = priority
        }
        
        if let deadline = deadline {
            json[Keys.deadlineKey] = deadline
        }
        
        if let taskEditDate = taskEditDate {
            json[Keys.taskEditDateKey] = taskEditDate
        }
        
        if let taskColor = hexColor {
            json[Keys.hexColorKey] = taskColor
        }
        
        return json
    }
    
    static func parseFrom(json: Any) -> TodoItem? {
        guard let json = json as? [String: Any] else { return nil }
        
        guard let id = json[Keys.idKey] as? String,
              let text = json[Keys.textKey] as? String,
              let taskDone = json[Keys.taskDoneKey] as? Bool,
              let taskStart = json[Keys.taskStartDateKey] as? Double
        else { return nil }
        
        let priority = json[Keys.priorityKey] as? String ?? TaskPriority.ordinary.rawValue
        
        let deadlineDate: Double?
        if let deadline = json[Keys.deadlineKey] as? Double {
            deadlineDate = deadline
        } else {
            deadlineDate = nil
        }
        
        let taskEdit: Double?
        if let taskEditDate = json[Keys.taskEditDateKey] as? Double {
            taskEdit = taskEditDate
        } else {
            taskEdit = nil
        }
        
        let taskColor: String?
        if let hexColor = json[Keys.hexColorKey] as? String  {
            taskColor = hexColor
        } else {
            taskColor = nil
        }
        
        let item = TodoItem(id: id,
                            text: text,
                            priority: priority,
                            taskDone: taskDone,
                            deadline: deadlineDate,
                            taskStartDate: taskStart,
                            taskEditDate: taskEdit,
                            hexColor: taskColor)
        return item
    }
}

extension TodoItem {
    private enum Keys {
        static let idKey = "id"
        static let textKey = "text"
        static let priorityKey = "priority"
        static let taskDoneKey = "taskDone"
        static let deadlineKey = "deadline"
        static let taskStartDateKey = "taskStartDate"
        static let taskEditDateKey = "taskEditDate"
        static let hexColorKey = "hexColor"
    }
}

//MARK: - parsing CSV
extension TodoItem {
    
    var csv: String {
        
        var csvString = ""
        csvString = csvString.appending("\(String(describing: id))")
        csvString += TodoItem.separator
        
        if text.contains(",") {
            let csvTask = text.replacingOccurrences(of: ",", with: " ")
            csvString = csvString.appending(csvTask)
        } else {
            csvString = csvString.appending("\(String(describing: text))")
        }
        
        csvString += TodoItem.separator
        
        if priority != TaskPriority.ordinary.rawValue {
            csvString = csvString.appending(String(describing: priority))
        } else {
            csvString += " "
        }
        
        csvString += TodoItem.separator
        
        let done = String(describing: taskDone)
        if done == "false" {
            csvString = csvString.appending("no")
        } else {
            csvString = csvString.appending("yes")
        }
        
        csvString += TodoItem.separator
        
        if let deadline = deadline {
            let strDeadline = String(describing: deadline.timeInSecondsToDateString())
            if strDeadline.contains(",") {
                let csvDeadline = strDeadline.replacingOccurrences(of: ",", with: " ")
                csvString = csvString.appending(csvDeadline)
            } else {
                csvString = csvString.appending(strDeadline)
            }
        } else {
            csvString += " "
        }
        
        csvString += TodoItem.separator
        
        
        let taskStartDateString = taskStartDate.timeInSecondsToDateString()
        if taskStartDateString.contains(",") {
            let csvDate = taskStartDateString.replacingOccurrences(of: ",", with: " ")
            csvString = csvString.appending(csvDate)
        } else {
            csvString = csvString.appending("\(String(describing: taskStartDateString))")
        }
        
        csvString += TodoItem.separator
        
        
        if let editDate = taskEditDate {
            let editing = String(describing: editDate.timeInSecondsToDateString())
            if editing.contains(",") {
                let csvEditing = editing.replacingOccurrences(of: ",", with: " ")
                csvString = csvString.appending(csvEditing)
            } else {
                csvString = csvString.appending(editing)
            }
        } else {
            csvString += " "
        }
        
        csvString += "\n"
        
        return csvString
    }
    
    
    static func parseFromCSVFormat(csv: String) -> [TodoItem] {
        var items: [TodoItem] = []
        var rows = csv.components(separatedBy: "\n")
        //удаляем заголовки
        rows.removeFirst()
        
        for row in rows {
            let csvColumns = row.components(separatedBy: ",")
            if csvColumns.count == 7  {
                let task = TodoItem(id: csvColumns[0],
                                    text: csvColumns[1],
                                    priority: csvColumns[2] == " " ? TaskPriority.ordinary.rawValue : csvColumns[2],
                                    taskDone: csvColumns[3] == "yes" ? true : false,
                                    deadline: csvColumns[4] == " " ? nil : csvColumns[4].stringToDoubleDate(),
                                    taskStartDate:  csvColumns[5].stringToDoubleDate(),
                                    taskEditDate:csvColumns[6] == " " ? nil : csvColumns[6].stringToDoubleDate())
                items.append(task)
            }
        }
        return items
    }
}


