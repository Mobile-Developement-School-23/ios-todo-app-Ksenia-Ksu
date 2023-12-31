import UIKit
import ToDoItemModule

protocol DysplaysToDoList: UIView {
    func configure(with viewModel: DataFlow.FetchToDoes.ViewModel)
    func startLoading()
    func stopLoading()
}

protocol ToDoListDelegate: AnyObject {
    func didSelectItem(with id: String?, with cellFrame: CGRect?)

  // MARK: - in network
    func taskDoneStatusChangedInItem(with id: String)
    func deleteItem(with id: String)
    
    func createPreviewDetailVC(with id: String) -> UIViewController?
    func animate(animator: UIContextMenuInteractionCommitAnimating)
}

final class ToDoListView: UIView {
    
    weak var delegate: ToDoListDelegate?
    private let tableManager: ManagesToDoListTable
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .clear
        tableView.register(ToDoListTableViewCell.self, forCellReuseIdentifier: Layout.taskCellID)
        tableView.register(HeaderViewCell.self, forCellReuseIdentifier: Layout.headerCellID)
        tableView.register(NewTodoCell.self, forCellReuseIdentifier: Layout.newCellID)
        tableView.sectionHeaderHeight = 0.0
        tableView.sectionFooterHeight = 0.0
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    lazy var newTodoButton: UIButton = {
        var newTodoButton = UIButton()
        newTodoButton.setBackgroundImage(Layout.newTodoButtonImage, for: .normal)
        newTodoButton.layer.cornerRadius = 22
        newTodoButton.imageView?.contentMode = .scaleToFill
        newTodoButton.addTarget(self, action: #selector(addNewToDo), for: .touchUpInside)
        newTodoButton.translatesAutoresizingMaskIntoConstraints = false
        return newTodoButton
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    init(delegate: ToDoListDelegate? = nil, tableManager: ManagesToDoListTable = ToListTableViewManager()) {
        self.delegate = delegate
        self.tableManager = tableManager
        super.init(frame: .zero)
        tableView.dataSource = tableManager
        tableView.delegate = tableManager
        self.tableManager.delegate = self
        self.backgroundColor = ThemeColors.backPrimary
        addSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(tableView)
        addSubview(activityIndicator)
        addSubview(newTodoButton)
    }
    
    private func makeConstraints() {
        
        NSLayoutConstraint.activate([
            
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
        tableView.topAnchor.constraint(equalTo: topAnchor),
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
 
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        
        newTodoButton.centerXAnchor.constraint(equalTo: centerXAnchor),
        newTodoButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.newTodoButtonInset),
        newTodoButton.heightAnchor.constraint(equalToConstant: Layout.newTodoButtonHeight),
        newTodoButton.widthAnchor.constraint(equalToConstant: Layout.newTodoButtonWidth)
        ])
    }
    
    @objc func addNewToDo() {
        delegate?.didSelectItem(with: nil, with: nil)
    }
}
// MARK: - ToDoListTableManagerDelegate
extension ToDoListView: ToDoListTableManagerDelegate {
    
    func deleteItem(with id: String) {
        delegate?.deleteItem(with: id)
    }
    
    func editItem(with id: String) {
        delegate?.taskDoneStatusChangedInItem(with: id)
    }
    
    func animatorContext(animator: UIContextMenuInteractionCommitAnimating) {
        delegate?.animate(animator: animator)
    }
    
    func createDetailVC(with id: String) -> UIViewController? {
        delegate?.createPreviewDetailVC(with: id)
    }
        
    func didSelectItem(with id: String?, with cellFrame: CGRect?) {
        delegate?.didSelectItem(with: id, with: cellFrame)
    }
    
    func updateViewModel() {
        tableView.reloadData()
    }
    
    func didSelectedHeader() {
        tableView.reloadData()
    }
    
}

extension ToDoListView: DysplaysToDoList {
  
    func configure(with viewModel: DataFlow.FetchToDoes.ViewModel) {
        tableManager.dataForTableView = viewModel.todoList
        tableView.reloadData()
    }
    
    func startLoading() {
        tableView.reloadData()
        tableView.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
    }
    
    func stopLoading() {
        tableView.isHidden = false
        tableView.reloadData()
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}

extension ToDoListView {
    private enum Layout {
        static let headerHeight: CGFloat = 32
        static let headerInset: CGFloat = 24
        static let backgroundColor = ThemeColors.backPrimary
        static let doneLabelColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
        static let taskFont = 17
        static let taskCellID = "Cell"
        static let headerCellID = "header cell"
        static let newCellID = "new todo cell"
        static let newTodoButtonImage = UIImage(named: "plus-blue")
        static let newTodoButtonInset: CGFloat = 64
        static let newTodoButtonHeight: CGFloat = 44
        static let newTodoButtonWidth: CGFloat = 44
    }
}
