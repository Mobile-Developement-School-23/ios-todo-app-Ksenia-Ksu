import Foundation
import ToDoItemModule
import CocoaLumberjackSwift

protocol Provides: AnyObject {
    func getTodoList(completion: @escaping (Result<[TodoItem], Error>) -> Void)
    func getSelectedTodo(at index: Int) -> TodoItem
    func taskStatusDidChanged(with id: String)
    func deleteTask(with id: String)
}

final class Provider: Provides {
   
    private let service: FileCaching
    private let fileName = "Data"
    private let test = TodoItem(text: "test provider")
   
    init(service: FileCaching) {
        self.service = service
    }
    
    func getTodoList(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        service.load(named: fileName) { result in
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
    
    func getSelectedTodo(at index: Int) -> TodoItem {
        return test
    }
    
    func taskStatusDidChanged(with id: String) {
            if let todo = service.deleteTask(with: id) {
                service.addTask(task: TodoItem(id: todo.id,
                                               text: todo.text,
                                               priority: todo.priority,
                                               taskDone: todo.taskDone == false ? true : false,
                                               deadline: todo.deadline,
                                               taskStartDate: todo.taskStartDate,
                                               taskEditDate: Double(Date().timeIntervalSince1970),
                                               hexColor: todo.hexColor))
                service.saveAllTasksToJSONFile(named: fileName)
            }
        
    }
    
    func deleteTask(with id: String) {
        if service.deleteTask(with: id) != nil {
            service.saveAllTasksToJSONFile(named: fileName)
        }
    }
}
