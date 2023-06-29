import UIKit
import ToDoItemModule

protocol ManagesToDoListTable: UITableViewDataSource, UITableViewDelegate {
    
    var dataForTableView: [ToDoViewModel] { get set }
    var delegate: ToDoListTableManagerDelegate? { get set }
}

protocol ToDoListTableManagerDelegate: AnyObject {
    func didSelectedHeader()
    func didSelectItem(with id: Int)
}

final class ToListTableViewManager: NSObject, ManagesToDoListTable, HeaderViewDelegate, ToDoListTableViewCellDelegate {
    
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
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: headerCellID) as? HeaderViewCell
            cell?.headerViewDelegate = self
            return cell ?? UITableViewCell()
        } else if indexPath.section == 1 {
            if indexPath.row < dataForTableView.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: taskCellID) as? ToDoListTableViewCell
                cell?.todoCellDelagate = self
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
    
    func showButtonTapped() {
       
    }
    
    func taskDoneButtonTapped() {
        delegate?.didSelectedHeader()
    }
    
 }
