import Foundation
import ToDoItemModule
import CocoaLumberjackSwift

protocol RetryManagerDelegate: AnyObject {
    
    func showSpinner(_: Bool)
    
    func listIsDirty()
}

final class RetryManager: NetworkServiceProtocol {
    
    weak var delegate: RetryManagerDelegate?
    private let networkService: NetworkService
    private let minDelay = 2.0
    private let maxDelay = 120.0
    private let factor = 1.5
    private let jitter = 0.05
    private let exp = 2.7
    private var getAllCount = 0
    private var updateCount = 0
    private var editCount = 0
    private var deleteCount = 0
    private var addCount = 0
    private var getCount = 0
    
    private lazy var retries: [Double] = {
        var tempResults: [Double] = []
        var delay = minDelay
        var count = 0.0
        var resultDelay = 2.0
        var realResult = 2.0
        repeat {
            resultDelay = delay * pow(exp, count)
            var randomization = resultDelay * jitter
            var lower = resultDelay - randomization
            var upper = resultDelay + randomization
            realResult = Double.random(in: lower...upper)
            if realResult > maxDelay { break }
            if count == 0 && realResult < 2.0 {
                realResult = 2.0
            }
            tempResults.append(realResult)
            count += 1
        } while realResult <= maxDelay
        return tempResults
    }()
    
    init() {
        self.networkService = NetworkService()
    }
    
    // MARK: - get All
    
    func getAllItems(completion: @escaping (Result<[ToDoItemModule.TodoItem], Error>) -> Void) {
        delegate?.showSpinner(true)
        networkService.getAllItems { result in
            switch result {
            case .success(let items):
                self.getAllCount = 0
                completion(.success(items))
                self.delegate?.showSpinner(false)
                return
            case .failure(let error):
                self.getAllCount += 1
                if self.getAllCount > 5 {
                    self.getAllCount = 0
                    self.delegate?.listIsDirty()
                    self.delegate?.showSpinner(false)
                    completion(.failure(error))
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + self.retries[self.getAllCount - 1]) {
                    self.delegate?.showSpinner(false)
                    self.getAllItems { result in
                        switch result {
                        case .success(let items):
                            self.getAllCount = 0
                            completion(.success(items))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                        
                    }
                }
            }
        }
    }
    // MARK: - update
    func updateItemsList(_ list: [TodoItem], completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        self.delegate?.showSpinner(true)
        self.networkService.updateItemsList(list) { result in
            switch result {
            case .success(let items):
                completion(.success(items))
                self.updateCount = 0
                self.delegate?.showSpinner(false)
                return
            case .failure(let error):
                self.updateCount += 1
                if self.updateCount > 5 {
                    self.updateCount = 0
                    self.delegate?.listIsDirty()
                    self.delegate?.showSpinner(false)
                    completion(.failure(error))
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + self.retries[self.updateCount - 1]) {
                    self.delegate?.showSpinner(false)
                    self.updateItemsList(list) { result in
                        switch result {
                        case .success(let items):
                            self.updateCount = 0
                            completion(.success(items))
                            return
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - getItem
    func getItem(with id: String, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        delegate?.showSpinner(true)
        networkService.getItem(with: id) { result in
            switch result {
            case .success(let itemFromNetwork):
                self.getCount = 0
                completion(.success(itemFromNetwork))
                self.delegate?.showSpinner(false)
            case .failure(let error):
                self.getCount += 1
                if self.getCount > 5 {
                    self.getCount = 0
                    self.delegate?.listIsDirty()
                    self.delegate?.showSpinner(false)
                    completion(.failure(error))
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + self.retries[self.getCount - 1]) {
                    self.delegate?.showSpinner(false)
                    self.getItem(with: id) { result in
                        switch result {
                        case .success(let itemFromNetwork):
                            self.getCount = 0
                            completion(.success(itemFromNetwork))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
    }
    // MARK: - edit
    func editItem(_ item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        delegate?.showSpinner(true)
        networkService.editItem(item) { result in
            switch result {
            case .success(let itemFromNetwork):
                self.editCount = 0
                completion(.success(itemFromNetwork))
                self.delegate?.showSpinner(false)
            case .failure(let error):
                if error as? NetworkErrors == NetworkErrors.wrongRevision {
                    self.delegate?.listIsDirty()
                    self.delegate?.showSpinner(false)
                    completion(.failure(NetworkErrors.wrongRevision))
                    return
                }
                self.editCount += 1
                if self.editCount > 5 {
                    self.editCount = 0
                    self.delegate?.listIsDirty()
                    self.delegate?.showSpinner(false)
                    completion(.failure(error))
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + self.retries[self.editCount - 1]) {
                    self.delegate?.showSpinner(false)
                    self.editItem(item) { result in
                        switch result {
                        case .success(let itemFromNetwork):
                            self.editCount = 0
                            completion(.success(itemFromNetwork))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
    }
    // MARK: - add
    func addItem(_ item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        delegate?.showSpinner(true)
        networkService.addItem(item) { result in
            switch result {
            case .success(let itemFromNetwork):
                self.addCount = 0
                completion(.success(itemFromNetwork))
                self.delegate?.showSpinner(false)
            case .failure(let error):
                if error as? NetworkErrors == NetworkErrors.wrongRevision {
                    self.delegate?.listIsDirty()
                    self.delegate?.showSpinner(false)
                    completion(.failure(NetworkErrors.wrongRevision))
                    return
                }
                self.addCount += 1
                if self.addCount > 5 {
                    self.addCount = 0
                    self.delegate?.showSpinner(false)
                    self.delegate?.showSpinner(false)
                    completion(.failure(error))
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + self.retries[self.addCount - 1]) {
                    self.delegate?.showSpinner(false)
                    self.addItem(item) { result in
                        switch result {
                        case .success(let itemFromNetwork):
                            self.addCount = 0
                            completion(.success(itemFromNetwork))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
    }
    // MARK: - delete
    func deleteItem(with id: String, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        delegate?.showSpinner(true)
        networkService.deleteItem(with: id) { result in
            switch result {
            case .success(let itemFromNetwork):
                self.deleteCount = 0
                completion(.success(itemFromNetwork))
                self.delegate?.showSpinner(false)
            case .failure(let error):
                if error as? NetworkErrors == NetworkErrors.wrongRevision {
                    self.delegate?.listIsDirty()
                    self.delegate?.showSpinner(false)
                    completion(.failure(NetworkErrors.wrongRevision))
                    return
                }
                self.deleteCount += 1
                if self.deleteCount > 5 {
                    self.deleteCount = 0
                    self.delegate?.listIsDirty()
                    self.delegate?.showSpinner(false)
                    completion(.failure(NetworkErrors.unknownServerError))
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + self.retries[self.deleteCount - 1]) {
                    self.delegate?.showSpinner(false)
                    self.deleteItem(with: id) { result in
                        switch result {
                        case .success(let itemFromNetwork):
                            self.deleteCount = 0
                            completion(.success(itemFromNetwork))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
    }
}
