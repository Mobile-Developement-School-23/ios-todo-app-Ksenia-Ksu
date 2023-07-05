import UIKit

protocol ColorPickerViewDelegate: AnyObject {
    func cancelChanges()
    func saveColor(color: UIColor?)
}

final class ColorSelectionView: UIView {
    
    weak var colorPickerViewDelegate: ColorPickerViewDelegate?
    
    private lazy var colorButton: UIButton = {
        let colorButton = UIButton()
        colorButton.layer.cornerRadius = Layout.buttonCornerRadius
        colorButton.layer.borderWidth = Layout.buttonBorderWidth
        colorButton.layer.borderColor = UIColor.black.cgColor
        colorButton.translatesAutoresizingMaskIntoConstraints = false
        return colorButton
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.setTitle(Layout.cancelButtonText, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.layer.cornerRadius = Layout.buttonCornerRadius
        cancelButton.backgroundColor = Layout.cancelButtonColor
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        return cancelButton
    }()
    
    private lazy var saveButton: UIButton = {
        let saveButton = UIButton()
        saveButton.setTitle(Layout.saveButtonText, for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        saveButton.layer.cornerRadius = Layout.buttonCornerRadius
        saveButton.backgroundColor = Layout.saveButtonColor
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        return saveButton
    }()
    
    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.value = 0
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.isContinuous = true
        slider.tintColor = UIColor.green
        slider.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private lazy var colorView: HSBColorPicker = {
        let view = HSBColorPicker()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(delegate: ColorPickerViewDelegate) {
        super.init(frame: .zero)
        colorPickerViewDelegate = delegate
        colorView.delegate = self
        backgroundColor = .white
        addSubviews()
        makeConstraits()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func saveButtonTapped() {
        let color = colorButton.backgroundColor
        colorPickerViewDelegate?.saveColor(color: color)
    }
    
    @objc func cancelButtonTapped() {
        colorPickerViewDelegate?.cancelChanges()
    }
    
    @objc func sliderValueDidChange(_ sender: UISlider) {
        let color = colorButton.backgroundColor
        colorButton.backgroundColor = color?.withBrightness(CGFloat(sender.value))
    }
    
    private func addSubviews() {
        addSubview(colorButton)
        addSubview(saveButton)
        addSubview(slider)
        addSubview(colorView)
        addSubview(cancelButton)
    }
    
    private func makeConstraits() {
        NSLayoutConstraint.activate([
            colorButton.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor, constant: Layout.indent),
            colorButton.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            colorButton.widthAnchor.constraint(equalToConstant: Layout.buttonWidth),
            colorButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
            
            saveButton.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor, constant: Layout.indent),
            saveButton.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: Layout.buttonWidth),
            saveButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
            
            cancelButton.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor, constant: Layout.indent),
            cancelButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: Layout.buttonWidth),
            cancelButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
            
            slider.topAnchor.constraint(equalTo: colorButton.bottomAnchor, constant: Layout.indent),
            slider.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            
            colorView.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: Layout.indent),
            colorView.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            colorView.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor)
        ])
    }
}

// MARK: - HSBColorPickerDelegate
extension ColorSelectionView: HSBColorPickerDelegate {
    func HSBColorColorPickerTouched(sender: HSBColorPicker, color: UIColor, point: CGPoint, state: UIGestureRecognizer.State) {
        let currentBrightness = color.brightness
        colorButton.backgroundColor = color
        slider.setValue(Float(currentBrightness), animated: true)
        let title = String(color.hexStringFromColor())
        colorButton.setTitle(title, for: .normal)
    }
}

extension ColorSelectionView {
    private enum Layout {
        static let saveButtonText = "Сохранить"
        static let cancelButtonText = "Отменить"
        static let buttonHeight: CGFloat = 50
        static let buttonWidth: CGFloat = 100
        static let indent: CGFloat = 16
        static let buttonCornerRadius: CGFloat = 10
        static let buttonBorderWidth: CGFloat = 1
        static let saveButtonColor = UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1)
        static let cancelButtonColor = UIColor(red: 0, green: 0.48, blue: 1.0, alpha: 1.0)
    }
}
