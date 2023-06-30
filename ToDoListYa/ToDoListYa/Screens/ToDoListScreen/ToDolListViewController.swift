import UIKit
import ToDoItemModule

protocol DisplayLogic: AnyObject {
    func displayFetchedTodoes(_ viewModel: DataFlow.FetchToDoes.ViewModel)
    func displaySelectedTodo(_ viewModel: DataFlow.SelectToDo.ViewModel)
    func displayNewTask()
}

final class ToDoListViewController: UIViewController {
    
    lazy var contentview: DysplaysToDoList = ToDoListView(delegate: self)
    private let interactor: ToDoListBusinessLogic
    
    init (interactor: ToDoListBusinessLogic) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = contentview
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navBarSetup()
        print("loaded")
        interactor.fetchTodoList(.init())
    }
    
    private func navBarSetup() {
        navigationItem.title = "Мои дела"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.sizeToFit()
    }
}
                                                          
extension ToDoListViewController: ToDoListDelegate {
    
    func deleteTask(with id: String) {
        interactor.deleteTask(with: id)
    }
    
    func taskDoneStatusChangedInTask(with id: String) {
        interactor.todoChangedStatus(with: id)
    }
    
    func addNewTask() {
        displayNewTask()
    }
    
    #warning("rewrite logic")
    func didSelectItem(with id: Int) {
        let vc = DetailViewController()
        present(vc, animated: true)
    }
}

extension ToDoListViewController: DisplayLogic {
    
    func displayNewTask() {
        let vc = DetailViewController()
        present(vc, animated: true)
    }
    
    func displayFetchedTodoes(_ viewModel: DataFlow.FetchToDoes.ViewModel) {
        contentview.configure(with: .init(todoList: viewModel.todoList))
        
    }
    
    func displaySelectedTodo(_ viewModel: DataFlow.SelectToDo.ViewModel) {
        
    }
}
