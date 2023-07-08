import UIKit

struct TodoListModuleBuilder {
    func build() -> UIViewController {
        let serviceCaheJson = FileCache()
        let newtworkService = NetworkService()
        let provider = Provider(serviceCacheJson: serviceCaheJson, networkService: newtworkService)
        let presenter = TodoListPresenter()
        let interactor = TodoListInteractor(presenter: presenter, provider: provider)
        let vc = ToDoListViewController(interactor: interactor)
        presenter.controller = vc
        return vc
    }
}
