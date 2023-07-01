import UIKit
import ToDoItemModule
import CocoaLumberjackSwift

protocol DetailDelegate: AnyObject {
    func updateTodoList()
}

final class DetailViewController: UIViewController {
    
    lazy var contentView: DisplayDetailView = DetailView(delegate: self)
    
    private var dummyItem: DummyToDoItem?
    private let fileManager = FileCache()
    private let data = "Data"
    var taskID: String?
    var tasks = [TodoItem]()
    weak var delegate: DetailDelegate?
    
    override func loadView() {
        view = contentView
    }
    
    init(taskID: String? = nil) {
        self.taskID = taskID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogVerbose("Did load detail view")
        let loadedTasks =  fileManager.loadTasksFromJSONFile(named: data)
        if taskID == nil {
            contentView.configure(with: nil)
            dummyItem = DummyToDoItem(text: "")
        } else {
            if let currentTasks = loadedTasks {
                tasks = currentTasks
            }
            if tasks != [] && taskID != nil {
                let items = tasks.filter { $0.id == taskID }
                if items != [] {
                    let item = items.first!
                    dummyItem = DummyToDoItem(id: item.id,
                                              text: item.text,
                                              priority: item.priority,
                                              taskDone: item.taskDone,
                                              deadline: item.deadline,
                                              taskStartDate: item.taskStartDate,
                                              taskEditDate: item.taskEditDate,
                                              hexColor: item.hexColor)
                    contentView.configure(with: item)
                }
            }
        }
    }
}

extension DetailViewController: DetailViewDelegate {
    
    func openColorController() {
        let colorPickerVC = ColorViewController(colorHandler: self)
        present(colorPickerVC, animated: true)
    }
    
    func saveItem(with text: String, color: String?) {
        if let model = dummyItem {
            let newItem = TodoItem(id: model.id,
                                   text: text,
                                   priority: model.priority,
                                   taskDone: model.taskDone,
                                   deadline: model.deadline,
                                   taskStartDate: model.taskStartDate,
                                   taskEditDate: model.taskEditDate,
                                   hexColor: color)
            fileManager.addTask(task: newItem)
            fileManager.saveAllTasksToJSONFile(named: data)
        }
        delegate?.updateTodoList()
        dismiss(animated: true)
    }
    
    func deleteItem() {
        if let id = taskID {
            fileManager.deleteTask(with: id)
            fileManager.saveAllTasksToJSONFile(named: data)
            dummyItem = nil
            contentView.configure(with: nil)
            dummyItem = DummyToDoItem(text: "new task")
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
        print("cancel")
        delegate?.updateTodoList()
        dismiss(animated: true)
    }
}
// MARK: - ColorPikerSelectedDelegate
extension DetailViewController: ColorPikerSelectedDelegate {
    
    func addColorToModel(color: UIColor) {
        if let model = dummyItem {
            model.hexColor = color.hexStringFromColor()
            contentView.configureColor(color: color)
        }
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
