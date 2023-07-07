import Foundation
import ToDoItemModule

struct TodoItems: Codable {
    let status: String
    let revision: Int32
    let list: [TodoItemBackend]
    
}

struct PatchItems: Codable {
    let list: [TodoItemBackend]
}

struct Item: Codable {
    let status: String
    let element: TodoItemBackend
    let revision: Int32
}

struct PostItem: Codable {
    let element: TodoItemBackend
}

struct TodoItemBackend: Codable {
    let id: String
    let text: String
    let importance: String
    let deadline: Int64?
    let done: Bool
    let color: String?
    let createdAt: Int64
    let changedAt: Int64
    let lastUpdatedBy: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case importance
        case deadline
        case done
        case color
        case createdAt = "created_at"
        case changedAt = "changed_at"
        case lastUpdatedBy = "last_updated_by"
    }
}

extension TodoItemBackend {
    var convertedItemFromBack: TodoItem {
        var priority = TaskPriority.ordinary
        
        if self.importance == "low" {
            priority = .unimportant
        } else if self.importance == "high" {
            priority = .important
        }
        
        var deadline: Double?
        
        if let deadlineFromBack = self.deadline {
            deadline = Double(deadlineFromBack)
        }
        
        let taskEditDate = Double(changedAt)
        let taskStartDate = Double(createdAt)
        
        let convertedItemFromBack = TodoItem(id: id,
                                             text: text,
                                             priority: priority.rawValue,
                                             taskDone: done,
                                             deadline: deadline,
                                             taskStartDate: taskStartDate,
                                             taskEditDate: taskEditDate,
                                             hexColor: color)
        return convertedItemFromBack
    }
}

extension TodoItem {
    var convertedItemToBack: TodoItemBackend {
        var importance = "basic"
        if self.priority == TaskPriority.unimportant.rawValue {
            importance = "low"
        } else if self.priority == TaskPriority.important.rawValue {
            importance = "important"
        }
        
        var deadline: Int64 = 0
        
        if let deadlineToBack = self.deadline {
            deadline = Int64(deadlineToBack)
        }
        
        var changedAt: Int64 = Int64(Date().timeIntervalSince1970)
        if let editDateFromBack = self.taskEditDate {
            changedAt = Int64(editDateFromBack)
        }
        
        let convertedItemToBack = TodoItemBackend(id: id,
                                                  text: text,
                                                  importance: importance,
                                                  deadline: deadline,
                                                  done: taskDone,
                                                  color: hexColor,
                                                  createdAt: Int64(taskStartDate),
                                                  changedAt: changedAt,
                                                  lastUpdatedBy: UIDevice.current.identifierForVendor?.uuidString ?? "none")
        return convertedItemToBack
    }
}
