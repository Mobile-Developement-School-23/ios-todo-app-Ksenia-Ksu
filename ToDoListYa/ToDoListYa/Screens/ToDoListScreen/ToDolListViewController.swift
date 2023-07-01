import UIKit
import ToDoItemModule
import CocoaLumberjackSwift

protocol DisplayLogic: AnyObject {
    func displayFetchedTodoes(_ viewModel: DataFlow.FetchToDoes.ViewModel)
}

final class ToDoListViewController: UIViewController {
    
    lazy var contentview: DysplaysToDoList = ToDoListView(delegate: self)
    private let interactor: ToDoListBusinessLogic
    private var cellSelectedFrame: CGRect?
    
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
        DDLogVerbose("Did load todolist view")
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
    
#warning("rewrite logic")
    func didSelectItem(with id: String?, with cellFrame: CGRect?) {
        cellSelectedFrame = cellFrame
        let vc = DetailViewController(taskID: id)
        vc.delegate = self
        vc.modalPresentationStyle = .automatic
        vc.transitioningDelegate = self
        present(vc, animated: true)
        
    }
}

extension ToDoListViewController: DisplayLogic {
    
    func displayFetchedTodoes(_ viewModel: DataFlow.FetchToDoes.ViewModel) {
        contentview.configure(with: .init(todoList: viewModel.todoList))
        
    }
    
}

extension ToDoListViewController: DetailDelegate {
    
    func updateTodoList() {
        interactor.fetchTodoList(.init())
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension ToDoListViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let startFrame = cellSelectedFrame else { return nil }
        return PresentFromCellAnimator(cellFrame: startFrame)
    }
}
