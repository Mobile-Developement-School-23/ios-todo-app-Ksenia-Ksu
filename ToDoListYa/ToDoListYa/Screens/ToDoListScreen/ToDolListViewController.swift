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
        contentview.startLoading()
        interactor.fetchTodoList(.init())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    private func navBarSetup() {
        navigationItem.title = "Мои дела"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.layoutMargins.left = 32
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.sizeToFit()
    }
    
}

extension ToDoListViewController: ToDoListDelegate {
    
    func animate(animator: UIContextMenuInteractionCommitAnimating) {
        guard let viewController = animator.previewViewController else { return }
        animator.addCompletion {
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    func createPreviewDetailVC(with id: String) -> UIViewController? {
        let vc = DetailModuleBuilder().build(with: id, delegate: self)
        return vc
    }
    
    func taskDoneStatusChangedInItem(with id: String) {
        interactor.todoChangedStatusInItem(with: id)
    }
    
    func deleteItem(with id: String) {
        interactor.deleteTask(with: id)
    }
    
    func didSelectItem(with id: String?, with cellFrame: CGRect?) {
        cellSelectedFrame = cellFrame
        let vc = DetailModuleBuilder().build(with: id, delegate: self)
        vc.modalPresentationStyle = .automatic
        vc.transitioningDelegate = self
        present(vc, animated: true)
    }
}

extension ToDoListViewController: DisplayLogic {
    
    func displayFetchedTodoes(_ viewModel: DataFlow.FetchToDoes.ViewModel) {
        contentview.configure(with: .init(todoList: viewModel.todoList))
        contentview.stopLoading()
        
    }
}

extension ToDoListViewController: DetailDelegate {
    
    func updateTodoList() {
        contentview.startLoading()
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



