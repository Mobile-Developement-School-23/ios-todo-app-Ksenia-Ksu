import UIKit

struct DetailModuleBuilder {
    func build(with task: String?) -> UIViewController {
       // let service = FileCache()
        //let provider = Provider(service: service)
        //let presenter = TodoListPresenter()
       // let interactor = TodoListInteractor(presenter: presenter, provider: provider)
        let vc = DetailViewController(taskID: task)
        //presenter.controller = vc
        return vc
    }
}

