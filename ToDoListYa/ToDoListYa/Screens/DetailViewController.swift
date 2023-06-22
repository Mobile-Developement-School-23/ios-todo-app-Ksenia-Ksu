import UIKit

class DetailViewController: UIViewController {
    
    lazy var contentView: DisplayDetailView = DetailView(delegate: self)
    
    private var item: TodoItem?
    private let fileManager = FileCache()
    private let data = "Data"
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewModel = fileManager.loadTasksFromJSONFile(named: data)
        if let viewModel = viewModel, viewModel.count > 0 {
            item = viewModel[0]
            contentView.configure(with: item!)
            print(item)
        } else {
            contentView.configure(with: nil)
        }
    }
}

extension DetailViewController: DetailViewDelegate {
    
    func saveItem(with text: String) {
        //модель в любом случае должна быть, потому что кнопка  save не активна, пока не произойдут изменения
        if let model = item {
            let newItem = TodoItem(id: model.id,
                                   text: text,
                                   priority: model.priority,
                                   taskDone: model.taskDone,
                                   deadline: model.deadline,
                                   taskStartDate: model.taskStartDate,
                                   taskEditDate: model.taskEditDate)
        //fileManager.addTask(task: item)
        //fileManager.saveAllTasksToJSONFile(named: data)
        }
            print("item saved")
        }
    
    func deleteItem() {
        if let model = item {
            //fileManager.deleteTask(with: model.id)
            //fileManager.saveAllTasksToJSONFile(named: data)
            print("deleted and saved file \(model)")
        }
    }
    
    func changePriority(to priority: TaskPriority) {
        if var model = item {
            let newItem = TodoItem(id: model.id,
                                   text: model.text, priority: priority.rawValue, taskDone: model.taskDone, deadline: model.deadline, taskStartDate: model.taskStartDate, taskEditDate: model.taskEditDate)
            item = newItem
            print(newItem)
        } else {
            // если модель отсутсвует значит создаётся новая задача с изменённым приоритетом
            let newItem = TodoItem(text: "",
                                   priority: priority.rawValue)
            item = newItem
        }
        
    }
    
    func addDeadline(to newDeadline: Double) {
        if let model = item {
            let newItem = TodoItem(id: model.id,
                                   text: model.text,
                                   priority: model.priority,
                                   taskDone: model.taskDone,
                                   deadline: newDeadline,
                                   taskStartDate: model.taskStartDate,
                                   taskEditDate: model.taskEditDate)
            item = newItem
            print(newItem)
        }
    }
    
    func deleteDeadline() {
        if let model = item {
            let newItem = TodoItem(id: model.id,
                                   text: model.text,
                                   priority: model.priority,
                                   taskDone: model.taskDone,
                                   deadline: nil,
                                   taskStartDate: model.taskStartDate,
                                   taskEditDate: model.taskEditDate)
            item = newItem
            print(newItem)
        
        }
        // else быть не может, так как по умолчанию в новой задаче нет дедлайна, создастся модель когда он установится
    }
    
    func cancelChanges() {
        // загружается снова тот же item из файла, пока логика такая
        print("cancel")
//        let viewModel = fileManager.loadTasksFromJSONFile(named: data)
//        if let viewModel = viewModel, viewModel.count > 0 {
//            item = viewModel[0]
//            contentView.configure(with: item!)
//            print(item)
//        } else {
//            contentView.configure(with: nil)
//        }
    }
    
}

