import UIKit

struct TodoListModuleBuilder {
    func build() -> UIViewController {
        let serviceCaheJson = FileCache()
        let newtworkService = NetworkService()
        let coreDataService = CoreDataManager.shared
        let provider = Provider(serviceCacheJson: serviceCaheJson, networkService: newtworkService, coreDataStorage: coreDataService)
        let presenter = TodoListPresenter()
        let interactor = TodoListInteractor(presenter: presenter, provider: provider)
        let vc = ToDoListViewController(interactor: interactor)
        presenter.controller = vc
        return vc
    }
}
