import UIKit
import ToDoItemModule

protocol ManagesToDoListTable: UITableViewDataSource, UITableViewDelegate {
    
    var dataForTableView: [ToDoViewModel] { get set }
    var delegate: ToDoListTableManagerDelegate? { get set }
}

protocol ToDoListTableManagerDelegate: AnyObject {
    func didSelectedHeader()
    func didSelectItem(with id: Int)
    func taskDoneIsChangedInItem(with id: String)
    func updateViewModel()
    func deleteItem(with id: String)
    func buttonTapped()
}

final class ToListTableViewManager: NSObject, ManagesToDoListTable {
    
    private let taskCellID = "Cell"
    private let headerCellID = "header cell"
    private let newTodoCellID = "new todo cell"
    
    var dataForTableView: [ToDoViewModel] = []
    
    weak var delegate: ToDoListTableManagerDelegate?
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return dataForTableView.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellfor row")
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: headerCellID) as? HeaderViewCell
            cell?.headerViewDelegate = self
            return cell ?? UITableViewCell()
        } else if indexPath.section == 1 {
            if indexPath.row < dataForTableView.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: taskCellID) as? ToDoListTableViewCell
                cell?.todoCellDelagate = self
                cell?.configureToDoCell(with:
                                            dataForTableView[indexPath.row])
                return cell ?? UITableViewCell()
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: newTodoCellID) as? NewTodoCell
                return cell ?? UITableViewCell()
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            delegate?.didSelectedHeader()
        } else {
            delegate?.didSelectItem(with: indexPath.row)
        }
    }
    
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
            #warning("дописать функцию info")
        }
        infoAction.image = Layout.info
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, _ in
            guard let deletedModelId = self?.dataForTableView[indexPath.row].id else { return }
            self?.delegate?.deleteItem(with: deletedModelId)
            self?.dataForTableView.remove(at: indexPath.row)
            self?.delegate?.updateViewModel()
        }
        deleteAction.image = Layout.delete
        
        return UISwipeActionsConfiguration(actions: [deleteAction, infoAction])
        
    }
    
}

extension ToListTableViewManager: HeaderViewDelegate {
    func showDoneTasks() {
        delegate?.didSelectedHeader()
    }
}

extension ToListTableViewManager: ToDoListTableViewCellDelegate {
    func taskDoneButtonTapped() {
        print("manager")
        delegate?.buttonTapped()
    }
}

extension ToListTableViewManager {
    private enum Layout {
        static let leftSwipe = UIImage(systemName: "checkmark.circle.fill")
        static let info = UIImage(systemName: "info.circle.fill")
        static let delete = UIImage(systemName: "trash.fill")
    }
}
