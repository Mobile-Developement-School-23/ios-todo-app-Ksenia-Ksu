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

final class NetworkService: NetworkServiceProtocol {
    
    private(set) var revision: Int32 = 0
    
    private let queue = DispatchQueue(label: "Network queue", attributes: [.concurrent])
    
    // MARK: - GET ALL
    
    func getAllItems(completion: @escaping (Result<[ToDoItemModule.TodoItem], Error>) -> Void) {
        queue.async {
            let url = RequestCreator.createURL(Constants.url)
            guard let url = url else { return }
            let request = RequestCreator.createRequest(with: url,
                                                       httpMethod: HttpMethods.get)
            guard let request = request else { return }
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                if let data = data {
                    do {
                        var items: [TodoItem] = []
                        let result: TodoItems = try JSONDecoder().decode(TodoItems.self, from: data)
                        for todo in result.list {
                            items.append(todo.convertedItemFromBack)
                        }
                        self.revision = result.revision
                        DispatchQueue.main.async {
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
            guard let url = RequestCreator.createURL(Constants.url) else { return }
            guard let request = RequestCreator.createRequest(with: url,
                                                             httpMethod: HttpMethods.patch,
                                                             httpBody: data,
                                                             revision: String(self.revision)) else { return }
    
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                
                if let data = data {
                    do {
                        var items: [TodoItem] = []
                        let result: TodoItems = try JSONDecoder().decode(TodoItems.self, from: data)
                        for item in result.list {
                            items.append(item.convertedItemFromBack)
                        }
                        
                        DispatchQueue.main.async {
                            self.revision = result.revision
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
            guard let url = RequestCreator.createURL(Constants.url,
                                                     item: id) else { return }
            guard let request = RequestCreator.createRequest(with: url,
                                                             httpMethod: HttpMethods.get) else { return }
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let data = data {
                    do {
                        let result: Item = try JSONDecoder().decode(Item.self, from: data)
                        let todoItem = result.element.convertedItemFromBack
                            DispatchQueue.main.async {
                                self.revision = result.revision
                                print("new revision after loading", self.revision)
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
    func addItem(_ item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        queue.async {
            let itemForBack = item.convertedItemToBack
            let body = PostItem(element: itemForBack)
            let data = try? JSONEncoder().encode(body)
            guard let url = URL(string: Constants.url) else { return }
            var request = URLRequest(url: url)
            request.httpMethod = HttpMethods.post.rawValue
            request.setValue(Constants.token, forHTTPHeaderField: Constants.auth)
            request.setValue(String(self.revision), forHTTPHeaderField: Constants.lastRevision)
            request.httpBody = data
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        let result: Item = try JSONDecoder().decode(Item.self, from: data)
                        let todoItem = result.element.convertedItemFromBack
                        DispatchQueue.main.async {
                            self.revision = result.revision
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
    func editItem(_ item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        queue.async {
            let item = item.convertedItemToBack
            let body = PostItem(element: item)
            let data = try? JSONEncoder().encode(body)
            guard let data = data else { return }
            
            guard let url = RequestCreator.createURL(Constants.url, item: item.id) else { return }
            let request = RequestCreator.createRequest(with: url,
                                                       httpMethod: HttpMethods.put, httpBody: data,
                                                       revision: String(self.revision))
            guard let request = request else { return }

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let data = data {
                    do {
                        let result: Item = try JSONDecoder().decode(Item.self, from: data)
                        let todoItem = result.element.convertedItemFromBack
                        DispatchQueue.main.async {
                             completion(.success(todoItem))
                             self.revision = result.revision
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
            guard let url = RequestCreator.createURL(Constants.url,
                                                     item: id) else { return }
            guard let request = RequestCreator.createRequest(with: url,
                                                             httpMethod: HttpMethods.delete,
                                                             revision: String(self.revision)
            ) else { return }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let data = data {
                    do {
                        let result: Item = try JSONDecoder().decode(Item.self, from: data)
                        let todoItem = result.element.convertedItemFromBack
                        DispatchQueue.main.async {
                            completion(.success(todoItem))
                            self.revision = result.revision
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
    static let token = "Bearer baffies"
    static let url = "https://beta.mrdekk.ru/todobackend/list"
}

enum NetworkErrors: Error {
    case incorrectUrl
    case wrongRequest
    case wrongAuth
    case noElementOnserver
    case unknownServerError
    case wrongRevision
}

private enum RequestCreator {
    static func createURL(_ baseURL: String, item id: String? = nil) -> URL? {
        var url = baseURL
        if let itemId = id {
            url += "/" + itemId
        }
        guard let url = URL(string: url) else { return nil }
        return url
    }
    
    static func createRequest(with url: URL, httpMethod: HttpMethods, httpBody: Data? = nil, revision: String? = nil) -> URLRequest? {
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        if let httpBody = httpBody {
            request.httpBody = httpBody
        }
        request.setValue(Constants.token, forHTTPHeaderField: Constants.auth)
        
        if let revision = revision {
            request.setValue(String(revision), forHTTPHeaderField: Constants.lastRevision)
        }
        
        return request
    }
}
