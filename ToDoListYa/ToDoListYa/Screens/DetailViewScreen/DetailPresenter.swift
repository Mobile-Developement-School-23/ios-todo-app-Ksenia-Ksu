import Foundation
import ToDoItemModule

protocol DetailPresentationLogic: AnyObject {
    func presentTodo(item: TodoItem)
    func presentNewItem()
    func closeController()
}

final class DetailPresenter: DetailPresentationLogic {
 
    weak var controller: DetailViewDisplayLogic?
    
    func presentTodo(item: TodoItem) {
        controller?.displayFetchedTodo(item)
    }
    
    func presentNewItem() {
        controller?.displayNewTodo()
    }
    
    func closeController() {
        controller?.updateToDoList()
    }

}
