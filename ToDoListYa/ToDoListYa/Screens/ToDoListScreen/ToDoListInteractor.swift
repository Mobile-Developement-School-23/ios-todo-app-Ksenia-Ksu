import Foundation
import ToDoItemModule
import CocoaLumberjackSwift

protocol ToDoListBusinessLogic {
    // MARK: - file cache
//    func fetchTodoListFromCache(_ request: DataFlow.FetchToDoes.Request)
//    func todoChangedStatusInCache(with id: String)
//    func deleteTaskInCache(with id: String)
    // MARK: - network
    func fetchTodoList(_ request: DataFlow.FetchToDoes.Request)
    func todoChangedStatusInItem(with id: String)
    func deleteTask(with id: String)
    
}

final class TodoListInteractor: ToDoListBusinessLogic {
   
    private let presenter: ToDoListPresentationLogic
    private let provider: Provides
    
    init(presenter: ToDoListPresentationLogic, provider: Provides) {
        self.presenter = presenter
        self.provider = provider
    }
    
    func fetchTodoListFromCache(_ request: DataFlow.FetchToDoes.Request) {
        provider.getTodoListFromCache { result in
            switch result {
            case .success(let items):
                self.presenter.presentFetchedTodoes(.init(todoList: items))
            case .failure(let error):
                DDLogError("Provider fetched data from cache with error - \(error.localizedDescription)")
            }
        }
    }
    
    func todoChangedStatusInCache(with id: String) {
        provider.taskStatusDidChangedInCache(with: id)
    }
    
    func deleteTaskInCache(with id: String) {
        provider.deleteTaskInCache(with: id)
    }
    
    func fetchTodoList(_ request: DataFlow.FetchToDoes.Request) {
        provider.getItemsList { result in
            switch result {
            case .success(let items):
                self.presenter.presentFetchedTodoes(.init(todoList: items))
            case .failure(let error):
                DDLogError("Provider fetched data from network with error - \(error.localizedDescription)")
            }
        }
    }
    
    func todoChangedStatusInItem(with id: String) {
        provider.getItemForEdit(with: id) { result in
            switch result {
            case .success(let item):
                #warning("дописать что делать с отредактированным")
            case .failure(let error):
                DDLogError("Provider увше item with error - \(error.localizedDescription)")
            }
        }
    }
   
    func deleteTask(with id: String) {
        provider.deleteItem(with: id) { result in
            switch result {
            case .success(let item):
                #warning("дописать что делать с удалённым")
            case .failure(let error):
                DDLogError("Provider delete item with error - \(error.localizedDescription)")
            }
        }
    }
    
}
