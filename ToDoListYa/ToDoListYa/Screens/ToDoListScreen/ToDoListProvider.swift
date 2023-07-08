import Foundation
import ToDoItemModule
import CocoaLumberjackSwift

protocol Provides: AnyObject {
    //file cache
    func getTodoListFromCache(completion: @escaping (Result<[TodoItem], Error>) -> Void)
    func taskStatusDidChangedInCache(with id: String)
    func deleteTaskInCache(with id: String)
    // network
    func getItemsList(completion: @escaping (Result<[TodoItem], Error>) -> Void)
    func getItemForEdit(with id: String, completion: @escaping (Result<TodoItem, Error>) -> Void)
    func deleteItem(with id: String, completion: @escaping (Result<TodoItem, Error>) -> Void)
    
}

final class Provider: Provides {
   
    private let serviceCacheJson: FileCaching
    private let networkService: NetworkServiceProtocol
    private let fileName = "Data"

    init(serviceCacheJson: FileCaching, networkService: NetworkServiceProtocol) {
        self.serviceCacheJson = serviceCacheJson
        self.networkService = networkService
    }
    // MARK: - file cache
    func getTodoListFromCache(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        serviceCacheJson.load(named: fileName) { result in
            switch result {
            case .success(let items):
                DispatchQueue.main.async {
                    completion(.success(items))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func taskStatusDidChangedInCache(with id: String) {
            if let todo = serviceCacheJson.deleteTask(with: id) {
                serviceCacheJson.addTask(task: TodoItem(id: todo.id,
                                               text: todo.text,
                                               priority: todo.priority,
                                               taskDone: todo.taskDone == false ? true : false,
                                               deadline: todo.deadline,
                                               taskStartDate: todo.taskStartDate,
                                               taskEditDate: Double(Date().timeIntervalSince1970),
                                               hexColor: todo.hexColor))
                serviceCacheJson.saveAllTasksToJSONFile(named: fileName)
            }
    }
    
    func deleteTaskInCache(with id: String) {
        if serviceCacheJson.deleteTask(with: id) != nil {
            serviceCacheJson.saveAllTasksToJSONFile(named: fileName)
        }
    }
    
    // MARK: - Network methods
    
    func getItemsList(completion: @escaping (Result<[ToDoItemModule.TodoItem], Error>) -> Void) {
        networkService.getAllItems { result in
            switch result {
            case .success(let items):
                DispatchQueue.main.async {
                    completion(.success(items))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func getItemForEdit(with id: String, completion: @escaping (Result<ToDoItemModule.TodoItem, Error>) -> Void) {
        networkService.getItem(with: id) { result in
            switch result {
            case .success(let item):
                DispatchQueue.main.async {
                    completion(.success(item))
                    let newItem = self.editItemSatus(item: item)
                    self.networkService.editItem(newItem) { result in
                        switch result {
                        case .success(let item):
                            DispatchQueue.main.async {
                                completion(.success(item))
                            }
                        case .failure(let error):
                            DispatchQueue.main.async {
                                completion(.failure(error))
                            }
                        }
                    }
                    
                    
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
   

    private func editItemSatus(item: TodoItem) -> TodoItem {
        return TodoItem(id: item.id,
                               text: item.text,
                               priority: item.priority,
                               taskDone: item.taskDone == true ? false : true,
                               deadline: item.deadline,
                               taskStartDate: item.taskStartDate,
                               taskEditDate: item.taskEditDate,
                               hexColor: item.hexColor)
        
    }
    
    func deleteItem(with id: String, completion: @escaping (Result<ToDoItemModule.TodoItem, Error>) -> Void) {
        networkService.deleteItem(with: id) { result in
            switch result {
            case .success(let item):
                DispatchQueue.main.async {
                    completion(.success(item))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
