import Foundation
import ToDoItemModule

protocol DetailBusinessLogic {
    func fetchTodo(with id: String?)
    func add(todo: TodoItem)
    func deleteTask(with id: String)
    // func fetchRevision()
    func editItem(editTask: TodoItem)
}

final class DetailInteractor: DetailBusinessLogic {
    
    private let networkService: NetworkServiceProtocol
    private let preseneter: DetailPresentationLogic
    private let coreDataService: CoreDataService
    
    init(networkService: NetworkServiceProtocol, presenter: DetailPresentationLogic, coreDataService: CoreDataService) {
        self.networkService = networkService
        self.preseneter = presenter
        self.coreDataService = coreDataService
    }
    
    func fetchTodo(with id: String?) {
        if let taskId = id {
            let item = coreDataService.loadOneItemFromCD(with: taskId)
            if let item = item {
                self.preseneter.presentTodo(item: item)
            } else {
                preseneter.presentNewItem()
            }
        }
    }
    
    func add(todo: TodoItem) {
        coreDataService.saveAllItemsToCD([todo])
        preseneter.closeController()
    }
    
    func editItem(editTask: TodoItem) {
        coreDataService.editItemCD(item: editTask)
        preseneter.closeController()
    }
    
    func deleteTask(with id: String) {
        coreDataService.deleteItemFromCD(with: id)
        preseneter.closeController()
    }
    
   // func fetchRevision() {
//        networkService.getAllItems { result in
//            switch result {
//            case.success(_):
//                print("revision is Write")
//            case .failure(_):
//                print("revision is wrong")
//            }
//        }
    //  }
}
