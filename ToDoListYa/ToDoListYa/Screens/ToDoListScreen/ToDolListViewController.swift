import UIKit
import ToDoItemModule

final class ToDoListViewController: UIViewController {
    
    lazy var contentview: DysplaysToDoList = ToDoListView(delegate: self)
    var viewmodel: [ToDoViewModel]?
    var testViewModel = ToDoViewModel(title: "task", priority: .important, deadline: "7 12 2021", taskDone: false)
    
    override func loadView() {
        view = contentview
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        contentview.configure(with: viewmodel ?? [testViewModel])
        navBarSetup()
            // Do any additional setup after loading the view.
    }
    
    private func navBarSetup() {
        navigationItem.title = "Мои дела"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.sizeToFit()
    }
}
                                                          
extension ToDoListViewController: ToDoListDelegate {
    #warning("rewrite logic")
    func didSelectItem(with id: Int) {
        let vc = DetailViewController()
        present(vc, animated: true)
    }
}
