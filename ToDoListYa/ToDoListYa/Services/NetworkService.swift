import Foundation
import ToDoItemModule
import CocoaLumberjackSwift

protocol NetworkServiceProtocol {
    
    func getAllItems(completion: @escaping (Result<[TodoItem], Error>) -> Void)
    
    func updateItemsList(_ list: [TodoItem], completion: @escaping (Result<[TodoItem], Error>) -> Void)
    
    func getItem(with id: String, completion: @escaping (Result<TodoItem, Error>) -> Void)
    
    func addItem(_ item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void)
    
    func editItem(_ item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void)
    
    func deleteItem(with id: String, completion: @escaping (Result<TodoItem, Error>) -> Void)
}

final class NewtworkService: NetworkServiceProtocol {
    
    private(set) var revision = "0"
    private let url = "https://beta.mrdekk.ru/todobackend"
    private let token: String
    private let queue = DispatchQueue(label: "Network queue", attributes: [.concurrent])
    
    init(token: String) {
        self.token = token
    }
    // MARK: - GET ALL
    
    func getAllItems(completion: @escaping (Result<[ToDoItemModule.TodoItem], Error>) -> Void) {
        queue.async {
            guard let url = URL(string: self.url) else { return }
            var request = URLRequest(url: url)
            request.httpMethod = HttpMethods.get.rawValue
            request.setValue(self.token, forHTTPHeaderField: Constants.auth)
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                if let data = data {
                    do {
                        var items: [TodoItem] = []
                        let result: TodoItems = try JSONDecoder().decode(TodoItems.self, from: data)
                        for todo in result.list {
                            items.append(todo.convertedItemFromBack)
                        }
                        DispatchQueue.main.async {
                            self.revision = String(result.revision)
                            completion(.success(items))
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
                
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
            }
            task.resume()
        }
    }
    
    // MARK: - UPDATE
    func updateItemsList(_ list: [TodoItem], completion: @escaping (Result<[ToDoItemModule.TodoItem], Error>) -> Void) {
        queue.async {
            
            var itemsFromBack: [TodoItemBackend] = []
            for item in list {
                itemsFromBack.append(item.convertedItemToBack)
            }
            let body = PatchItems(list: itemsFromBack)
            let data = try? JSONEncoder().encode(body)
            guard let data = data else { return }
            guard let url = URL(string: self.url + Constants.list) else { return }
            var request = URLRequest(url: url)
            request.httpMethod = HttpMethods.patch.rawValue
            request.setValue(self.token, forHTTPHeaderField: Constants.auth)
            request.setValue(self.revision, forHTTPHeaderField: Constants.lastRevision)
            request.httpBody = data
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                
                if let data = data {
                    do {
                        var items: [TodoItem] = []
                        let result: TodoItems = try JSONDecoder().decode(TodoItems.self, from: data)
                        for item in result.list {
                            items.append(item.convertedItemFromBack)
                        }
                        
                        DispatchQueue.main.async {
                            self.revision = String(result.revision)
                            completion(.success(items))
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
                
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                
            }
            task.resume()
        }
    }
    
    // MARK: - GET ONE ITEM
    func getItem(with id: String, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        queue.async {
            guard let url = URL(string: self.url + Constants.list + id) else { return }
            var request = URLRequest(url: url)
            request.httpMethod = HttpMethods.get.rawValue
            request.setValue(self.token, forHTTPHeaderField: Constants.auth)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let data = data {
                    do {
                        let result: Element = try JSONDecoder().decode(Element.self, from: data)
                        let todoItem = result.element.convertedItemFromBack
                        DispatchQueue.main.async {
                            self.revision = String(result.revision)
                            completion(.success(todoItem))
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
                
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 400 {
                        let error = NetworkErrors.wrongRequest
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                }
                
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
            }
            task.resume()
        }
    }
    
    // MARK: - ADD
    func addItem(_ item: TodoItem, completion: @escaping (Result<ToDoItemModule.TodoItem, Error>) -> Void) {
        queue.async {
            let toDoItem = item.convertedItemToBack
            let body = PostElement(element: toDoItem)
            let data = try? JSONEncoder().encode(body)
            guard let data = data else { return }
            guard let url = URL(string: self.url + Constants.list) else { return }
            var request = URLRequest(url: url)
            request.httpMethod = HttpMethods.post.rawValue
            request.setValue(self.token, forHTTPHeaderField: Constants.auth)
            request.setValue(self.revision, forHTTPHeaderField: Constants.lastRevision)
            request.httpBody = data
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let data = data {
                    do {
                        let result: Element = try JSONDecoder().decode(Element.self, from: data)
                        let todoItem = result.element.convertedItemFromBack
                        DispatchQueue.main.async {
                            self.revision = String(result.revision)
                            completion(.success(todoItem))
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
                
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 400 {
                        let error = NetworkErrors.wrongRequest
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                }
                
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                    
                }
                
            }
            task.resume()
        }
    }
    
    // MARK: - EDIT
    func editItem(_ item: TodoItem, completion: @escaping (Result<ToDoItemModule.TodoItem, Error>) -> Void) {
        
        queue.async {
            let item = item.convertedItemToBack
            let body = PostElement(element: item)
            let data = try? JSONEncoder().encode(body)
            guard let data = data else { return }
            
            guard let url = URL(string: self.url + Constants.list + item.id) else { return }
            var request = URLRequest(url: url)
            request.httpMethod = HttpMethods.put.rawValue
            request.setValue(self.token, forHTTPHeaderField: Constants.auth)
            request.setValue(self.revision, forHTTPHeaderField: Constants.lastRevision)
            request.httpBody = data
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let data = data {
                    do {
                        let result: Element = try JSONDecoder().decode(Element.self, from: data)
                        let todoItem = result.element.convertedItemFromBack
                        DispatchQueue.main.async {
                            completion(.success(todoItem))
                            self.revision = String(result.revision)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
                
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 400 {
                        let error = NetworkErrors.wrongRequest
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
                
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
            task.resume()
        }
    }
    
    // MARK: - DELETE
    func deleteItem(with id: String, completion: @escaping (Result<ToDoItemModule.TodoItem, Error>) -> Void) {
        queue.async {
            
            guard let url = URL(string: self.url + Constants.list + id) else { return }
            var request = URLRequest(url: url)
            request.httpMethod = HttpMethods.delete.rawValue
            request.setValue(self.token, forHTTPHeaderField: Constants.auth)
            request.setValue(self.revision, forHTTPHeaderField: Constants.lastRevision)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let data = data {
                    do {
                        let result: Element = try JSONDecoder().decode(Element.self, from: data)
                        let todoItem = result.element.convertedItemFromBack
                        DispatchQueue.main.async {
                            completion(.success(todoItem))
                            self.revision = String(result.revision)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
                
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 400 {
                        let error = NetworkErrors.wrongRequest
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                }
                
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
            }
            task.resume()
        }
    }
}

private enum HttpMethods: String {
    case get = "GET"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

private enum Constants {
    static let auth = "Authorization"
    static let lastRevision = "X-Last-Known-Revision"
    static let list = "/list"
    
}

private enum NetworkErrors: Error {
    case wrongRequest
    case wrongAuth
    case noElementOnserver
    case unknownServerError
}
