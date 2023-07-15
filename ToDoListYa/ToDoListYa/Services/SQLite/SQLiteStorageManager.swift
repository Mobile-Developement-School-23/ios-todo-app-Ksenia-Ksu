import Foundation
import SQLite
import ToDoItemModule

final class SQLiteStarageManager {
    
    private var db: Connection?
    
    private let items = Table("TodoItems")
    
    init() {
        do {
            db = try Connection(try pathToDBFile())
            createTable()
        } catch let error {
            print(error)
        }
    }
    
    // MARK: - Load
    
    func loadItemsFromSQL() -> [TodoItem] {
        guard let db = db else { return [] }
        var itemsList = [TodoItem]()
        do {
            let dbItems = try db.prepare(items)
            for item in dbItems {
                let todoItem = TodoItem(id: item[id],
                                        text: item[text],
                                        priority: item[priority],
                                        taskDone: item[taskDone],
                                        deadline: item[deadline]?.stringToDoubleDate(),
                                        taskStartDate: item[taskStartDate].stringToDoubleDate(),
                                        taskEditDate: item[taskEditDate]?.stringToDoubleDate(),
                                        hexColor: item[hexColor])
                itemsList.append(todoItem)
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
        return itemsList
    }
    
    // MARK: - delete
    
    func deleteItem(with ID: String) {
        guard let db = db else { return }
        
        let itemForDelete = items.filter(id == ID)
        do {
            try db.run(itemForDelete.delete())
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    // MARK: - update and Add item in one method
    
    func updateOrAdd(item: TodoItem) {
        guard let db = db else { return }
        var deadLine: String?
        if let deadlineItem = item.deadline {
            deadLine = deadlineItem.timeInSecondsToDateString()
        }
        var editDate: String?
        if let editDateItem = item.taskEditDate {
            editDate = editDateItem.timeInSecondsToDateString()
        }
        
        var color: String?
        if let hexColor = item.hexColor {
            color = hexColor
        }
        var startTask = item.taskStartDate.timeInSecondsToDateString()
        let rowId = try? db.run(items.insert(or: .replace,
                                             id <- item.id,
                                             text <- item.text,
                                             priority <- item.priority,
                                             taskDone <- item.taskDone,
                                             taskStartDate <- startTask,
                                             taskEditDate <- editDate,
                                             deadline <- deadLine,
                                             hexColor <- color))
        
    }
    
    private func pathToDBFile() throws -> String {
        let fileManager = FileManager.default
        let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //let path = directory.appendingPathComponent("DB.sqlite3").path
        let url = "\(directory.absoluteString)/DB.sqlite3"
        return url
    }
    
    private let id = Expression<String>(TableFields.id)
    private let text = Expression<String>(TableFields.text)
    private let taskDone = Expression<Bool>(TableFields.taskDone)
    private let priority = Expression<String>(TableFields.priority)
    private let taskStartDate = Expression<String>(TableFields.taskStartDate)
    private let taskEditDate = Expression<String?>(TableFields.taskEditDate)
    private let deadline = Expression<String?>(TableFields.deadline)
    private let hexColor = Expression<String?>(TableFields.hexColor)
    
    private func createTable() {
        guard let db = db else { return }
        do {
            try db.run(items.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(text)
                table.column(priority)
                table.column(taskDone)
                table.column(taskStartDate)
                table.column(taskEditDate)
                table.column(deadline)
                table.column(hexColor)
            })
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
}

extension SQLiteStarageManager {
    enum TableFields {
        static let id = "id"
        static let text = "text"
        static let priority = "priority"
        static let taskDone = "taskDone"
        static let deadline = "deadline"
        static let taskStartDate = "taskStartDate"
        static let taskEditDate = "taskEditDate"
        static let hexColor = "hexColor"
    }
}
