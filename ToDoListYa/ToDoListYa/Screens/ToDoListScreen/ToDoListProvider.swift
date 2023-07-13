import Foundation
import ToDoItemModule
import CocoaLumberjackSwift

protocol Provides: AnyObject {
    // file cache
    func saveTasksFromServerToJSON(items: [TodoItem])
    func getTodoListFromCache(completion: @escaping (Result<[TodoItem], Error>) -> Void)
    func taskStatusDidChangedInCache(with id: String)
    func deleteTaskInCache(with id: String)
    
    // network
    func getItemsList(completion: @escaping (Result<[TodoItem], Error>) -> Void)
    func getItemForEdit(with id: String, completion: @escaping (Result<TodoItem, Error>) -> Void)
    func deleteItem(with id: String, completion: @escaping (Result<TodoItem, Error>) -> Void)
    func updateItemsList(completion: @escaping (Result<[TodoItem], Error>) -> Void)
    
    // core data
    func loadItemsFromCD() -> [TodoItem]
    func saveAllItemsToCD(_ items: [TodoItem])
    func deleteItemFromCD(with id: String)
    func editItemCD(item: TodoItem)
    func loadOneItemFromCD(with id: String) -> TodoItem?
    
}

final class Provider: Provides {
  
    private let serviceCacheJson: FileCaching
    private let networkService: NetworkServiceProtocol
    private let fileName = "Data"
    private let coreDataStorage: CoreDataService

    init(serviceCacheJson: FileCaching, networkService: NetworkServiceProtocol, coreDataStorage: CoreDataService) {
        self.serviceCacheJson = serviceCacheJson
        self.networkService = networkService
        self.coreDataStorage = coreDataStorage
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
    
    func saveTasksFromServerToJSON(items: [TodoItem]) {
        for item in items {
            serviceCacheJson.reloadTasks()
            serviceCacheJson.addTask(task: item)
        }
    }
    
    // MARK: - Network methods
    
    func getItemsList(completion: @escaping (Result<[ToDoItemModule.TodoItem], Error>) -> Void) {
        networkService.getAllItems { result in
            switch result {
            case .success(let items):
                DispatchQueue.main.async {
                    completion(.success(items))
                    self.saveTasksFromServerToJSON(items: items)
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
                                self.serviceCacheJson.addTask(task: item)
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
                    self.serviceCacheJson.deleteTask(with: item.id)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func updateItemsList(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        var newItems: [TodoItem] = []
        serviceCacheJson.load(named: fileName) { result in
            switch result {
            case .success(let items):
                newItems = items
            case .failure(let error):
                DDLogError("\(error.localizedDescription) - cant load file from json")
            }
        }
        networkService.updateItemsList(newItems) { result in
            switch result {
            case .success(let items):
                completion(.success(items))
            case .failure(let error):
                completion(.failure(error))
            }
        }
       
    }
    
    // MARK: - core data
    
    func loadItemsFromCD() -> [TodoItem] {
        return coreDataStorage.loadItemsFromCD()
    }
    
    func saveAllItemsToCD(_ items: [TodoItem]) {
        coreDataStorage.saveAllItemsToCD(items)
    }
    
    func deleteItemFromCD(with id: String) {
        coreDataStorage.deleteItemFromCD(with: id)
    }
    
    func editItemCD(item: TodoItem) {
        coreDataStorage.editItemCD(item: item)
    }
    
    func loadOneItemFromCD(with id: String) -> TodoItem? {
        coreDataStorage.loadOneItemFromCD(with: id)
    }
    
}
