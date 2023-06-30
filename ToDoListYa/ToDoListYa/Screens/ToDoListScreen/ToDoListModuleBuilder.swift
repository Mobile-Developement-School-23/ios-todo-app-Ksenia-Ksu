import UIKit

struct TodoListModuleBuilder {
    func build() -> UIViewController {
        let service = FileCache()
        let provider = Provider(service: service)
        let presenter = TodoListPresenter()
        let interactor = TodoListInteractor(presenter: presenter, provider: provider)
        let vc = ToDoListViewController(interactor: interactor)
        presenter.controller = vc
        return vc
    }
}
