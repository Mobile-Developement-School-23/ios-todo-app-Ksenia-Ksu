import Foundation

struct ToDoViewModel {
    var id: String
    var title: String
    var priority: TaskPriority
    var deadline: String?
    var taskDone: Bool
    var textColor: String?
}
