import Foundation
import ToDoItemModule

enum DataFlow {
    enum FetchToDoes {
        
        struct Request {}
        
        struct Reponse {
            let todoList: [TodoItem]
        }
        
        struct ViewModel {
            let todoList: [ToDoViewModel]
        }
    }
    
    enum SelectToDo {
        
        struct Request {
            let index: Int
        }
        
        struct Response {
            let todoItem: TodoItem
        }
        
        struct ViewModel {
            let todoItem: ToDoViewModel
        }
    }
    
    enum SelectNewItem {
        
        struct Request {
            
        }
        
        struct Response {
            
        }
    }
    
    enum Error: LocalizedError {
        case fileAcssessFailed
        case wrongJSONFormat
    }
}
