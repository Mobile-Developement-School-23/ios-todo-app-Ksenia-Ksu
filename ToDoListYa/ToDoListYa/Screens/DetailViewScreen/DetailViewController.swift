import UIKit
import ToDoItemModule
import CocoaLumberjackSwift

protocol DetailDelegate: AnyObject {
    func updateTodoList()
}

protocol DetailViewDisplayLogic: AnyObject {
    func displayFetchedTodo(_ item: TodoItem)
    func displayNewTodo()
    func updateToDoList()
}

final class DetailViewController: UIViewController {
    
    lazy var contentView: DisplayDetailView = DetailView(delegate: self)
    private let interactor: DetailBusinessLogic
    let taskID: String?
    var isNew = false
    
    private var dummyItem: DummyToDoItem?
    weak var delegate: DetailDelegate?
    
    override func loadView() {
        view = contentView
    }
    
    init(interactor: DetailBusinessLogic, taskId: String?, delegate: DetailDelegate) {
        self.interactor = interactor
        self.taskID = taskId
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogVerbose("Did load detail view")
        contentView.startLoading()
       
        if let taskID = taskID {
            isNew = false
            interactor.fetchTodo(with: taskID)
        } else {
            isNew = true
            interactor.fetchRevision()
            contentView.stopLoading()
            displayNewTodo()
            dummyItem = DummyToDoItem(text: "")
        }
    }
}

extension DetailViewController: DetailViewDelegate {
    
    func openColorController() {
        let colorPickerVC = ColorViewController(colorHandler: self)
        present(colorPickerVC, animated: true)
    }
    
    func saveItem(with text: String, color: String?) {
        if isNew {
            if let model = dummyItem {
                let newItem = TodoItem(id: model.id,
                                                   text: text,
                                                   priority: model.priority,
                                                   taskDone: model.taskDone,
                                                   deadline: model.deadline,
                                                   taskStartDate: model.taskStartDate,
                                                   taskEditDate: model.taskEditDate,
                                                   hexColor: color)
                
                interactor.add(todo: newItem)
                print("save item is add")
            }
        } else {
            if let model = dummyItem {
                let newItem = TodoItem(id: model.id,
                                                   text: text,
                                                   priority: model.priority,
                                                   taskDone: model.taskDone,
                                                   deadline: model.deadline,
                                                   taskStartDate: model.taskStartDate,
                                                   taskEditDate: model.taskEditDate,
                                                   hexColor: color)
             
                interactor.editItem(editTask: newItem)
                print("save item is edit")
            }
        }
    }
    
    func deleteItem() {
        if let id = taskID {
            dummyItem = nil
            contentView.configure(with: nil)
            interactor.deleteTask(with: id)
            delegate?.updateTodoList()
            dismiss(animated: true)
        }
    }
    
    func changePriority(to priority: TaskPriority) {
        if let model = dummyItem {
            model.priority = priority.rawValue
        }
    }
    
    func addDeadline(to newDeadline: Double) {
        if let model = dummyItem {
            model.deadline = newDeadline
        }
    }
    
    func deleteDeadline() {
        if let model = dummyItem {
            model.deadline = nil
        }
    }
    
    func cancelChanges() {
        delegate?.updateTodoList()
        dismiss(animated: true)
    }
}
// MARK: - ColorPikerSelectedDelegate
extension DetailViewController: ColorPikerSelectedDelegate {
    
    func addColorToModel(color: UIColor) {
        if let model = dummyItem {
            model.hexColor = color.hexStringFromColor()
            dummyItem = model
            contentView.configureColor(color: color)
        }
    }
}

// MARK: - transition
extension DetailViewController {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        if UIDevice.current.orientation.isLandscape {
            contentView.configureWithLandscape()
        } else {
            contentView.configureWithNormal()
        }
    }
}

// MARK: - DetailViewDisplayLogic
extension DetailViewController: DetailViewDisplayLogic {
    func updateToDoList() {
        dismiss(animated: true)
        delegate?.updateTodoList()
    }
    
    func displayFetchedTodo(_ item: TodoItem) {
        contentView.configure(with: item)
        contentView.stopLoading()
        dummyItem = DummyToDoItem(id: item.id,
                                  text: item.text,
                                  priority: item.priority,
                                  taskDone: item.taskDone,
                                  deadline: item.deadline,
                                  taskStartDate: item.taskStartDate,
                                  taskEditDate: item.taskEditDate,
                                  hexColor: item.hexColor)
    }
    
    func displayNewTodo() {
        contentView.configure(with: nil)
        contentView.stopLoading()
    }
    
}

// MARK: - Dummy class for new Todo
extension DetailViewController {
    class DummyToDoItem {
        var id: String
        var text: String
        var priority: String
        var taskDone: Bool
        
        var deadline: Double?
        var taskStartDate: Double
        var taskEditDate: Double?
        var hexColor: String?
        
        public init(id: String = UUID().uuidString,
                    text: String,
                    priority: String = TaskPriority.ordinary.rawValue,
                    taskDone: Bool = false,
                    deadline: Double? = nil,
                    taskStartDate: Double = Double(Date().timeIntervalSince1970),
                    taskEditDate: Double? = nil,
                    hexColor: String? = nil
        ) { self.id = id
            self.text = text
            self.priority = priority
            self.taskDone = taskDone
            self.deadline = deadline
            self.taskStartDate = taskStartDate
            self.taskEditDate = taskEditDate
            self.hexColor = hexColor
        }
    }
}
