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
            provider.getItemsList { result in
                switch result {
                case .success(let items):
                    self.presenter.presentFetchedTodoes(.init(todoList: items))
                case .failure(let error):
                    self.isDirty = true
                    DDLogError("Provider fetched data from network with error - \(error.localizedDescription)")
                }
            }
    }
    
    func todoChangedStatusInItem(with id: String) {
        if isDirty {
            provider.updateItemsList { result in
                switch result {
                case .success(let items):
                    self.isDirty = false
                    self.presenter.presentFetchedTodoes(.init(todoList: items))
                case .failure(let error):
                    self.provider.taskStatusDidChangedInCache(with: id)
                    DDLogError("Items not update with error - \(error.localizedDescription)")
                }
            }
        } else {
            provider.getItemForEdit(with: id) { result in
                switch result {
                case .success(let item):
                    self.isDirty = false
                    #warning("дописать что делать с отредактированным?")
                case .failure(let error):
                    self.isDirty = true
                    DDLogError("Provider  item with error - \(error.localizedDescription)")
                }
            }
        }
    }
   
    func deleteTask(with id: String) {
        if isDirty {
            provider.updateItemsList { result in
                switch result {
                case .success(let items):
                    self.isDirty = false
                    self.presenter.presentFetchedTodoes(.init(todoList: items))
                case .failure(let error):
                    self.provider.taskStatusDidChangedInCache(with: id)
                    DDLogError("Items not update with error - \(error.localizedDescription)")
                }
            }
        } else {
            provider.deleteItem(with: id) { result in
                switch result {
                case .success(let item):
                    self.provider.deleteTaskInCache(with: item.id)
                    #warning("дописать что делать с удалённым")
                case .failure(let error):
                    DDLogError("Provider delete item with error - \(error.localizedDescription)")
                }
            }
        }
       
    }
    
}
