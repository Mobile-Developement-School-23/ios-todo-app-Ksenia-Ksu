import Foundation
import ToDoItemModule
import CocoaLumberjackSwift

protocol ToDoListBusinessLogic {
    func fetchTodoList(_ request: DataFlow.FetchToDoes.Request)
    func todoChangedStatusInItem(with id: String)
    func deleteTask(with id: String)
    
}

final class TodoListInteractor: ToDoListBusinessLogic {
    
    private let presenter: ToDoListPresentationLogic
    private let provider: Provides
    private var isDirty = false
    
    init(presenter: ToDoListPresentationLogic, provider: Provides) {
        self.presenter = presenter
        self.provider = provider
    }
    
    func fetchTodoList(_ request: DataFlow.FetchToDoes.Request) {
        // Core Data
        
        //        let items = provider.loadItemsFromCD()
        //        presenter.presentFetchedTodoes(.init(todoList: items))
        
        //  SQL
        
        let items = provider.loadItemsFromSQL()
        presenter.presentFetchedTodoes(.init(todoList: items))
    }
    
    func todoChangedStatusInItem(with id: String) {
        // Core Data
        
        //        if var item = provider.loadOneItemFromCD(with: id) {
        //            var status = true
        //            if item.taskDone == false {
        //                status = true
        //            } else {
        //                status = false
        //            }
        //            let newItem = TodoItem(id: item.id,
        //                                   text: item.text,
        //                                   priority: item.priority,
        //                                   taskDone: status,
        //                                   deadline: item.deadline,
        //                                   taskStartDate: item.taskStartDate,
        //                                   taskEditDate: Date().timeIntervalSince1970,
        //                                   hexColor: item.hexColor)
        //            provider.editItemCD(item: newItem)
        //        }
        
        // SQL
        
        let items = provider.loadItemsFromSQL().filter {$0.id == id}
        if let item = items.first {
            var status = true
            if item.taskDone == false {
                status = true
            } else {
                status = false
            }
            let newItem = TodoItem(id: item.id,
                                   text: item.text,
                                   priority: item.priority,
                                   taskDone: status,
                                   deadline: item.deadline,
                                   taskStartDate: item.taskStartDate,
                                   taskEditDate: Date().timeIntervalSince1970,
                                   hexColor: item.hexColor)
            provider.updateOrAddToSQL(item: newItem)
        }
    }
    
    func deleteTask(with id: String) {
        // Core Data
        provider.deleteItemFromCD(with: id)
        // SQL
        provider.deleteItemFromSQL(with: id)
    }
    
}
