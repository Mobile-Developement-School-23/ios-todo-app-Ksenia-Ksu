import UIKit
import ToDoItemModule

protocol ManagesToDoListTable: UITableViewDataSource, UITableViewDelegate {
    var dataForTableView: [ToDoViewModel] { get set }
    var delegate: ToDoListTableManagerDelegate? { get set }
}

protocol ToDoListTableManagerDelegate: AnyObject {
    func didSelectedHeader()
    func didSelectItem(with id: String?, with cellFrame: CGRect?)
    func taskDoneIsChangedInItem(with id: String)
    func updateViewModel()
    func deleteItem(with id: String)
    func createDetailVC(with id: String) -> UIViewController?
    func animatorContext(animator: UIContextMenuInteractionCommitAnimating)
}

final class ToListTableViewManager: NSObject, ManagesToDoListTable {
    
    private let taskCellID = "Cell"
    private let headerCellID = "header cell"
    private let newTodoCellID = "new todo cell"
    private var doneTasks: [ToDoViewModel] = []
    private var undoneTasks: [ToDoViewModel] = []
    private var showDonetasks = false
    
    var dataForTableView: [ToDoViewModel] = [] {
        didSet {
            doneTasks = dataForTableView.filter {$0.taskDone == true }
            undoneTasks = dataForTableView.filter {$0.taskDone == false }
            dataForTableView = undoneTasks + doneTasks
        }
    }
    
    weak var delegate: ToDoListTableManagerDelegate?
    
    // MARK: - Table DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if showDonetasks {
                return dataForTableView.count + 1
            } else {
                return dataForTableView.count + 1 - doneTasks.count - 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: headerCellID) as? HeaderViewCell
            cell?.headerViewDelegate = self
            cell?.configureDoneTasks(with: doneTasks.count)
            return cell ?? UITableViewCell()
        } else if indexPath.section == 1 {
            if indexPath.row < dataForTableView.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: taskCellID) as? ToDoListTableViewCell
                cell?.todoCellDelagate = self
                cell?.configureToDoCell(with:
                                            dataForTableView[indexPath.row])
                cell?.checkButton.tag = indexPath.row
                return cell ?? UITableViewCell()
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: newTodoCellID) as? NewTodoCell
                return cell ?? UITableViewCell()
            }
        }
        return UITableViewCell()
    }
    
    // MARK: - Table Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = tableView.indexPathForSelectedRow {
            if indexPath.section == 0 {
                // we do not need this
            } else if indexPath.section == 1 {
                guard let cell = tableView.cellForRow(at: indexPath) else { return }
                let cellFrame = tableView.convert(cell.frame, to: tableView.superview)
                if indexPath.row < dataForTableView.count {
                    let id = dataForTableView[indexPath.row].id
                    delegate?.didSelectItem(with: id, with: cellFrame)
                } else {
                    delegate?.didSelectItem(with: nil, with: cellFrame)
                }
            }
        }
    }
    
    // MARK: - Swipes
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if !(tableView.cellForRow(at: indexPath) is ToDoListTableViewCell) { return nil}
        
        let swipeCheckChanged = UIContextualAction(style: .normal, title: nil) { [weak self ] _, _, _ in
            guard let modelId = self?.dataForTableView[indexPath.row].id  else { return }
            self?.delegate?.taskDoneIsChangedInItem(with: modelId)
            if self?.dataForTableView[indexPath.row].taskDone == false {
                self?.dataForTableView[indexPath.row].taskDone = true
            } else {
                self?.dataForTableView[indexPath.row].taskDone = false
            }
            self?.delegate?.updateViewModel()
        }
        swipeCheckChanged.image = Layout.leftSwipe
        swipeCheckChanged.backgroundColor = .systemGreen
        return UISwipeActionsConfiguration(actions: [swipeCheckChanged])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if !(tableView.cellForRow(at: indexPath) is ToDoListTableViewCell) { return nil}
        
        let infoAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, _ in
            guard let modelId = self?.dataForTableView[indexPath.row].id else { return }
            self?.delegate?.didSelectItem(with: modelId, with: nil)
        }
        infoAction.image = Layout.info
        infoAction.backgroundColor = Layout.infoActionColor
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, _ in
            guard let deletedModelId = self?.dataForTableView[indexPath.row].id else { return }
            self?.delegate?.deleteItem(with: deletedModelId)
            self?.dataForTableView.remove(at: indexPath.row)
            self?.delegate?.updateViewModel()
        }
        deleteAction.image = Layout.delete
        
        return UISwipeActionsConfiguration(actions: [deleteAction, infoAction])
        
    }
    // MARK: - second star
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        
        let lastIndex = tableView.numberOfRows(inSection: 0) - 1
        guard indexPath.row != lastIndex else { return nil }
        
        let config = UIContextMenuConfiguration(identifier: indexPath as NSIndexPath,
                                                previewProvider: { () -> UIViewController? in
            let tappedTodoId = self.dataForTableView[indexPath.row].id
            return self.delegate?.createDetailVC(with: tappedTodoId)
        }, actionProvider: nil)
        return config
    }
    
    func tableView(_ tableView: UITableView,
                   willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                   animator: UIContextMenuInteractionCommitAnimating) {
        
        delegate?.animatorContext(animator: animator)
    }
}

extension ToListTableViewManager: HeaderViewDelegate {
    func showDoneTasks() {
        if showDonetasks == false {
            showDonetasks = true
        } else {
            showDonetasks = false
        }
        delegate?.didSelectedHeader()
    }
}

extension ToListTableViewManager: ToDoListTableViewCellDelegate {
    func taskDoneButtonTapped(with id: Int) {
        let index = id
        if index < dataForTableView.count {
            let modelId = dataForTableView[index].id
            delegate?.taskDoneIsChangedInItem(with: modelId)
            if dataForTableView[index].taskDone == false {
                dataForTableView[index].taskDone = true
            } else {
                dataForTableView[index].taskDone = false
            }
            delegate?.updateViewModel()
        }
    }
}

extension ToListTableViewManager {
    private enum Layout {
        static let leftSwipe = UIImage(systemName: "checkmark.circle.fill")
        static let info = UIImage(systemName: "info.circle.fill")
        static let delete = UIImage(systemName: "trash.fill")
        static let infoActionColor = UIColor(red: 0.82, green: 0.82, blue: 0.84, alpha: 1.00)
    }
}
