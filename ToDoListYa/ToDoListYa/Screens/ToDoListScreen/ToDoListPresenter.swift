import Foundation
import ToDoItemModule

protocol ToDoListPresentationLogic {
    func presentFetchedTodoes(_ response: DataFlow.FetchToDoes.Reponse)
    func presentSelectedTodo(_ response: DataFlow.FetchToDoes.Reponse)
}

final class TodoListPresenter: ToDoListPresentationLogic {
    
    weak var controller: DisplayLogic?
    
    func presentFetchedTodoes(_ response: DataFlow.FetchToDoes.Reponse) {
        let todoList = response.todoList.map {
            ToDoViewModel(id: $0.id,
                          title: $0.text,
                          priority: TaskPriority(rawValue: $0.priority) ?? .ordinary,
                          deadline: $0.deadline?.timeInSecondsToDateString(),
                          taskDone: $0.taskDone,
                          textColor: $0.hexColor)
        }
        controller?.displayFetchedTodoes(.init(todoList: todoList))
    }
    
    func presentSelectedTodo(_ response: DataFlow.FetchToDoes.Reponse) {
        
    }
}
