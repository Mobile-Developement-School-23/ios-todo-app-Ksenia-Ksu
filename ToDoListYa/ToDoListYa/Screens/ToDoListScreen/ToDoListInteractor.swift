import Foundation
import ToDoItemModule
import CocoaLumberjackSwift

protocol ToDoListBusinessLogic {
    func fetchTodoList(_ request: DataFlow.FetchToDoes.Request)
    func todoChangedStatus(with id: String)
    func deleteTask(with id: String)
}

final class TodoListInteractor: ToDoListBusinessLogic {
    
    private let presenter: ToDoListPresentationLogic
    private let provider: Provides
    
    init(presenter: ToDoListPresentationLogic, provider: Provides) {
        self.presenter = presenter
        self.provider = provider
    }
    
    func fetchTodoList(_ request: DataFlow.FetchToDoes.Request) {
        provider.getTodoList { result in
            switch result {
            case .success(let items):
                self.presenter.presentFetchedTodoes(.init(todoList: items))
            case .failure(let error):
                DDLogError("Provider fetched data with error - \(error.localizedDescription)")
            }
        }
    }
    
    func todoChangedStatus(with id: String) {
        provider.taskStatusDidChanged(with: id)
    }
    
    func deleteTask(with id: String) {
        provider.deleteTask(with: id)
    }
    
}
