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
        let items = provider.loadItemsFromCD()
        presenter.presentFetchedTodoes(.init(todoList: items))
    }
    
    func todoChangedStatusInItem(with id: String) {
        if var item = provider.loadOneItemFromCD(with: id) {
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
            provider.editItemCD(item: newItem)
        }
       
    }
   
    func deleteTask(with id: String) {
        provider.deleteItemFromCD(with: id)
    }
    
}
