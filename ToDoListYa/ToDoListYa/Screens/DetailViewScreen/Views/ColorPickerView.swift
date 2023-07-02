protocol ColorViewDelegate: AnyObject {
    func openColorController()
}

import UIKit

final class ColorPickerView: UIView {
    
    weak var colorViewDelegate: ColorViewDelegate?
    
    private lazy var colorButton: UIButton = {
        let colorButton = UIButton()
        colorButton.setTitle(Layout.colorButtonText, for: .normal)
        colorButton.setTitleColor(.systemBlue, for: .normal)
        colorButton.titleLabel?.font = UIFont.systemFont(ofSize: Layout.fontSize, weight: .regular)
        colorButton.translatesAutoresizingMaskIntoConstraints = false
        colorButton.addTarget(self, action: #selector(colorButtonTapped), for: .touchUpInside)
        return colorButton
    }()

    lazy var colorSelectedButton: UIButton = {
        let colorSelectedButton = UIButton()
        colorSelectedButton.layer.cornerRadius = Layout.cornerRadius
        colorSelectedButton.layer.borderWidth = Layout.borderWidth
        colorSelectedButton.layer.borderColor = UIColor.black.cgColor
        colorSelectedButton.translatesAutoresizingMaskIntoConstraints = false
        return colorSelectedButton
    }()
    
    private lazy var separatorView: UIView = {
        let separatorView = UIView()
        separatorView.backgroundColor = ThemeColors.separatorColor
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        return separatorView
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = ThemeColors.backSecondary
        addSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(colorSelectedButton)
        addSubview(colorButton)
        addSubview(separatorView)
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            colorSelectedButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            colorSelectedButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.inset),
            colorSelectedButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeigh),
            colorSelectedButton.widthAnchor.constraint(equalToConstant: Layout.buttonHeigh),
            
            colorButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            colorButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.inset),
            colorButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeigh),
            
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.lineInsets.left),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Layout.lineInsets.right),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: Layout.separatorHeight)
        ])
    }
    
    @objc func colorButtonTapped() {
        colorViewDelegate?.openColorController()
    }
    
    func confugureColor(color: UIColor) {
        colorSelectedButton.backgroundColor = color
    }
}

extension ColorPickerView {
    private enum Layout {
        static let colorButtonText = "Цвет дела"
        static let fontSize: CGFloat = 17
        static let separatorHeight = 0.5
        static let lineInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        static let inset: CGFloat = 16
        static let buttonHeigh: CGFloat = 40
        static let cornerRadius: CGFloat = 20
        static let borderWidth: CGFloat = 1
    }
}
