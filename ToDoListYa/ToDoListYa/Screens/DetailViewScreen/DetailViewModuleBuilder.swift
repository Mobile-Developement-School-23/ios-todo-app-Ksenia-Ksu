import UIKit

struct DetailModuleBuilder {
    func build(with task: String?, delegate: DetailDelegate) -> UIViewController {
        let networkService = NetworkService()
        let presenter = DetailPresenter()
        let interactor = DetailInteractor(networkService: networkService, presenter: presenter)
        let vc = DetailViewController(interactor: interactor, taskId: task, delegate: delegate)
        presenter.controller  = vc
        return vc
    }
}
