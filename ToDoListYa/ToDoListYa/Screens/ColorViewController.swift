import UIKit

protocol ColorPikerSelectedDelegate: AnyObject {
    func addColorToModel(color: UIColor)
}

final class ColorViewController: UIViewController {
    
    weak var colorHandler: ColorPikerSelectedDelegate?

    lazy var colorView = ColorSelectionView(delegate: self)
    
    init(colorHandler: ColorPikerSelectedDelegate? = nil) {
        self.colorHandler = colorHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = colorView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

extension ColorViewController: ColorPickerViewDelegate {
    
    func cancelChanges() {
        dismiss(animated: true)
    }
    
    func saveColor(color: UIColor?) {
        if let color = color {
            colorHandler?.addColorToModel(color: color)
        }
        dismiss(animated: true)
    }
}
