import Foundation
import ToDoItemModule

protocol DetailBusinessLogic {
    func fetchTodo(with id: String?)
    func add(todo: TodoItem)
    func deleteTask(with id: String)
    func fetchRevision()
    func editItem(editTask: TodoItem) 
}

final class DetailInteractor: DetailBusinessLogic {
  
    private let networkService: NetworkServiceProtocol
    private let preseneter: DetailPresentationLogic
    
    init(networkService: NetworkServiceProtocol, presenter: DetailPresentationLogic) {
        self.networkService = networkService
        self.preseneter = presenter
    }
    
    func fetchTodo(with id: String?) {
        if let taskId = id {
            networkService.getItem(with: taskId) { result in
                switch result {
                case .success(let item):
                    DispatchQueue.main.async {
                        self.preseneter.presentTodo(item: item)
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        self.preseneter.presentNewItem()
                    }
                }
            }
        }
    }
    
    func add(todo: TodoItem) {
        networkService.addItem(todo) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.preseneter.closeController()
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self.preseneter.closeController()
                }
            }
        }
    }
    
    func editItem(editTask: TodoItem) {
        networkService.editItem(editTask) { result in
            switch result {
            case .success(let item):
                DispatchQueue.main.async {
                    print("edited")
                    self.preseneter.closeController()
                }
            case .failure(_):
                DispatchQueue.main.async {
                    print("not edited")
                }
            }
        }
    }
   
    
    func deleteTask(with id: String) {
        networkService.deleteItem(with: id) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.preseneter.presentNewItem()
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self.preseneter.presentNewItem()
                }
            }
        }
    }
    
    func fetchRevision() {
        networkService.getAllItems { result in
            switch result {
            case.success(_):
                print("revision")
            case .failure(_):
                print("no revision")
            }
        }
    }
}
