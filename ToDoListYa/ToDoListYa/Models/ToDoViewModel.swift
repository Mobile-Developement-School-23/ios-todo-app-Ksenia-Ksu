import Foundation
import ToDoItemModule

struct ToDoViewModel {
    let title: String
    let priority: TaskPriority
    let deadline: String?
    let taskDone: Bool
}
