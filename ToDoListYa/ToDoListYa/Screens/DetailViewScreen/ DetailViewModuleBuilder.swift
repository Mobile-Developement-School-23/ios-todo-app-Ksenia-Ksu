import UIKit

struct DetailModuleBuilder {
    func build(with task: String?) -> UIViewController {
        let vc = DetailViewController(taskID: task)
        return vc
    }
}
