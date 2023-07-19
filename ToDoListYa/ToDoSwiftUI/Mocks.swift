import Foundation

var items = [TodoItemMock(id: "123", text: "Test is not responsible dddddddddddddddddddddddddddddddddddddddddddddddddddddddd", priority: "important", taskDone: false, deadline: 1688139389.185488, taskStartDate: 1688093088.004704, hexColor: "#63DF24FF"), TodoItemMock(id: "1234", text: "Test2", priority: "low", taskDone: true, deadline:  1688139389.185488, taskStartDate: 1688093088.004704, hexColor: "#DF2424FF")]

struct TodoItemMock: Equatable, Identifiable {
    public let id: String
    public let text: String
    public let priority: String
    public let taskDone: Bool
    
    public let deadline: Double?
    public let taskStartDate: Double
    public let taskEditDate: Double?
    public let hexColor: String?
    
    public init(id: String = UUID().uuidString,
                text: String,
                priority: String = TaskPriority.basic.rawValue,
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

public enum TaskPriority: String {
    case important
    case basic
    case low
}


