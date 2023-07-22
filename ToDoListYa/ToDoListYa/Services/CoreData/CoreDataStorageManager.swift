import Foundation
import UIKit
import CoreData
import ToDoItemModule

protocol CoreDataService {
    func saveAllItemsToCD(_ items: [TodoItem])
    func loadItemsFromCD() -> [TodoItem]
    func deleteItemFromCD(with id: String)
    func editItemCD(item: TodoItem)
    func loadOneItemFromCD(with id: String) -> TodoItem?
}

final class CoreDataManager: NSObject, CoreDataService {
    
    static let shared = CoreDataManager()
    
    private override init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ModelCd")
        container.loadPersistentStores { description, error in
            if let error {
                print(error.localizedDescription)
            } else {
                 print("Core data adress - ", description.url?.absoluteString)
            }
        }
        return container
    }()
    
    // for reading
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // for saving
    //    func backGroundContext() -> NSManagedObjectContext {
    //        return persistentContainer.newBackgroundContext()
    //    }
    
    func saveContext() {
        let context = mainContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - save all, it can save one if needed
    func saveAllItemsToCD(_ items: [TodoItem]) {
        items.forEach {
            let _ = convertItemToCDItem(item: $0)
            saveContext()
        }
    }
    
    func saveItemToCD(_ item: TodoItem) {
        let _ = convertItemToCDItem(item: item)
        saveContext()
    }
    // MARK: - load all
    func loadItemsFromCD() -> [TodoItem] {
        var items = [TodoItem]()
        let fetchRequest = TodoItemCD.fetchRequest()
        
        do {
            let results = try mainContext.fetch(fetchRequest)
            for item in results {
                items.append(convertFromCDItem(itemCD: item))
            }
        } catch let error {
            print(error.localizedDescription)
        }
        
        return items
    }
    // MARK: - delete
    func deleteItemFromCD(with id: String) {
        let fetchRequest = TodoItemCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            let results = try mainContext.fetch(fetchRequest)
            for item in results {
                mainContext.delete(item)
            }
            try mainContext.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - edit
    func editItemCD(item: TodoItem) {
        let fetchRequest = TodoItemCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", item.id)
        
        do {
            let results = try mainContext.fetch(fetchRequest)
            for itemCD in results {
                itemCD.text = item.text
                itemCD.priority = item.priority
                itemCD.taskDone = item.taskDone
                itemCD.taskStartDate = item.taskStartDate.timeInSecondsToDateString()
                itemCD.deadline = item.deadline?.timeInSecondsToDateString()
                itemCD.taskEditDate = item.taskEditDate?.timeInSecondsToDateString()
                itemCD.hexColor = item.hexColor
            }
            try mainContext.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func loadOneItemFromCD(with id: String) -> TodoItem? {
        var items = [TodoItem]()
        let fetchRequest = TodoItemCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            let results = try mainContext.fetch(fetchRequest)
            if let firstItem = results.first {
                return convertFromCDItem(itemCD: firstItem)
            }
        } catch let error {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    
}

// MARK: - Convert
extension CoreDataManager {
    private func convertItemToCDItem(item: TodoItem) -> TodoItemCD {
        let itemCD = TodoItemCD(context: mainContext)
        itemCD.id = item.id
        itemCD.text = item.text
        itemCD.taskDone = item.taskDone
        itemCD.priority = item.priority
        itemCD.taskStartDate = item.taskStartDate.timeInSecondsToDateString()
        itemCD.taskEditDate = item.taskEditDate?.timeInSecondsToDateString()
        itemCD.hexColor = item.hexColor
        itemCD.deadline = item.deadline?.timeInSecondsToDateString()
        return itemCD
    }
    
    private func convertFromCDItem(itemCD: TodoItemCD) -> TodoItem {
        let item = TodoItem(id: itemCD.id,
                            text: itemCD.text,
                            priority: itemCD.priority,
                            taskDone: itemCD.taskDone,
                            deadline: itemCD.deadline?.stringToDoubleDate(),
                            taskStartDate: itemCD.taskStartDate.stringToDoubleDate(),
                            taskEditDate: itemCD.taskEditDate?.stringToDoubleDate(),
                            hexColor: itemCD.hexColor)
        return item
    }
}

extension CoreDataManager {
    private enum CoreDataErrors {
        case loadingError
        case savingError
    }
}
