import UIKit
import ToDoItemModule

protocol DisplayDetailView: UIView {
    func configure(with viewmodel: TodoItem?)
    func configureColor(color: UIColor)
    func configureWithLandscape()
    func configureWithNormal()
}

protocol DetailViewDelegate: AnyObject {
    func saveItem(with text: String, color: String?)
    func deleteItem()
    func cancelChanges()
    func changePriority(to priority: TaskPriority)
    func addDeadline(to newDeadline: Double)
    func deleteDeadline()
    func openColorController()
}

final class DetailView: UIView {
    
    private weak var delegate: DetailViewDelegate?
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var topStackView: UIStackView = {
        let topStackView = UIStackView()
        topStackView.axis = .horizontal
        topStackView.alignment = .center
        topStackView.distribution = .fillEqually
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        return topStackView
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.setTitle(Layout.cancelButtonText, for: .normal)
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.setTitleColor(.systemGray2, for: .disabled)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: Layout.fontSize, weight: .regular)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        return cancelButton
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = Layout.titleLabelText
        titleLabel.font = UIFont.systemFont(ofSize: Layout.fontSize, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    private lazy var saveButton: UIButton = {
        let saveButton = UIButton()
        saveButton.setTitle(Layout.saveButtonText, for: .normal)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        saveButton.setTitleColor(.systemGray2, for: .disabled)
        saveButton.isEnabled = false
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: Layout.fontSize, weight: .semibold)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        return saveButton
    }()
    
    private lazy var mainStackView: UIStackView = {
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = Layout.lineSpacing
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        return mainStackView
    }()
    
    private lazy var textView: DetailTextView = {
        let textView = DetailTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.keyboardType = .default
        textView.isUserInteractionEnabled = true
        textView.textViewDelegate = self
        return textView
    }()
    
    private lazy var containerForViews: UIStackView = {
        let containerForViews = UIStackView()
        containerForViews.layer.cornerRadius = Layout.cornerRadius
        containerForViews.layer.masksToBounds = true
        containerForViews.axis = .vertical
        containerForViews.translatesAutoresizingMaskIntoConstraints = false
        return containerForViews
    }()
    
    private lazy var coloPickerView: ColorPickerView = {
        let coloPickerView = ColorPickerView()
        coloPickerView.colorViewDelegate = self
        coloPickerView.backgroundColor = ThemeColors.backSecondary
        coloPickerView.translatesAutoresizingMaskIntoConstraints = false
        return coloPickerView
    }()
    
    private lazy var priorityView: PriorityView = {
        let priorityView = PriorityView()
        priorityView.setPriority(priority: TaskPriority.ordinary)
        priorityView.priorityVewDelegate = self
        priorityView.translatesAutoresizingMaskIntoConstraints = false
        return priorityView
    }()
    
    private lazy var deadlineView: DeadlineView = {
        let deadlineView = DeadlineView()
        deadlineView.deadlineViewDelegate = self
        deadlineView.translatesAutoresizingMaskIntoConstraints = false
        return deadlineView
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.backgroundColor = ThemeColors.backSecondary
        datePicker.locale = Locale(identifier: "ru")
        datePicker.addTarget(self, action: #selector(datePickerTapped(sender:)), for: .valueChanged)
        datePicker.isHidden = true
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    private lazy var deleteButton: UIButton = {
        let deleteButton = UIButton()
        deleteButton.setTitle(Layout.deleteButtonText, for: .normal)
        deleteButton.layer.cornerRadius = Layout.cornerRadius
        deleteButton.layer.masksToBounds = true
        deleteButton.backgroundColor = ThemeColors.backSecondary
        deleteButton.setTitleColor(.systemGray2, for: .disabled)
        deleteButton.setTitleColor(.systemRed, for: .normal)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: Layout.fontSize, weight: .regular)
        deleteButton.isEnabled = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return deleteButton
    }()
    
    init(delegate: DetailViewDelegate) {
        super.init(frame: .zero)
        self.delegate = delegate
        backgroundColor = Layout.backgroundcolor
        addTapGestureToHideKeyboard()
        addSubviews()
        makeConstraits()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(topStackView)
        topStackView.addArrangedSubview(cancelButton)
        topStackView.addArrangedSubview(titleLabel)
        topStackView.addArrangedSubview(saveButton)
        addSubview(scrollView)
        scrollView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(textView)
        mainStackView.addArrangedSubview(containerForViews)
        containerForViews.addArrangedSubview(coloPickerView)
        containerForViews.addArrangedSubview(priorityView)
        containerForViews.addArrangedSubview(deadlineView)
        containerForViews.addArrangedSubview(datePicker)
        mainStackView.addArrangedSubview(deleteButton)
    }
    // MARK: - Constraits
    private func makeConstraits() {
        let keyboardConstrait = scrollView.bottomAnchor.constraint(equalTo: self.keyboardLayoutGuide.topAnchor)
        keyboardConstrait.priority = .defaultLow
        NSLayoutConstraint.activate([
            
            topStackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: Layout.lineSpacing),
            topStackView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            topStackView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            
            scrollView.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: Layout.scrollViewInsets.top),
            scrollView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor,
                                                constant: Layout.scrollViewInsets.left),
            scrollView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor,
                                                 constant: Layout.scrollViewInsets.right),
            keyboardConstrait,
            
            mainStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            mainStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            coloPickerView.heightAnchor.constraint(equalToConstant: Layout.cellsHeight),
            
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.textViewHeight),
            coloPickerView.heightAnchor.constraint(equalToConstant: Layout.cellsHeight),
            priorityView.heightAnchor.constraint(equalToConstant: Layout.cellsHeight),
            deadlineView.heightAnchor.constraint(equalToConstant: Layout.cellsHeight),
            deleteButton.heightAnchor.constraint(equalToConstant: Layout.cellsHeight)
        ])
    }
    
    // MARK: - Actions
    @objc func cancelButtonTapped() {
        delegate?.cancelChanges()
        cancelButton.isEnabled = false
        deleteButton.isEnabled = false
    }
    
    @objc func saveButtonTapped() {
        let text = textView.text
        let color = coloPickerView.colorSelectedButton.backgroundColor
        if text != nil {
            var selectedColor: UIColor?
            if color != .white {
                selectedColor = color
            }
            delegate?.saveItem(with: text!, color: selectedColor?.hexStringFromColor())
            print("saving")
        }
    }
    
    @objc func datePickerTapped(sender: UIDatePicker) {
        let newDeadline = sender.date
        let dateDouble = Double(newDeadline.timeIntervalSince1970)
        deadlineView.setDeadline(date: dateDouble)
        UIView.animate(withDuration: Double(0.4), animations: {
            sender.isHidden = true
        })
        deadlineView.controlSeparatorView()
        delegate?.addDeadline(to: dateDouble)
    }
    
    @objc func deleteButtonTapped() {
        delegate?.deleteItem()
    }
    
    private func addTapGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.endEditing))
        // важный метод! без него не происходит нажатие на дату в календаре
        tapGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(tapGesture)
    }
    
    private func datePickerHide() {
        UIView.animate(withDuration: Double(0.3), animations: {
            self.datePicker.isHidden = true
        })
    }
    
    private func datePickerShow() {
        UIView.animate(withDuration: Double(0.3), animations: {
            self.datePicker.isHidden = false
        })
    }
}
// MARK: - DisplayDetailView
extension DetailView: DisplayDetailView {
    
    func configure(with viewmodel: TodoItem?) {
        if viewmodel != nil {
            textView.text = viewmodel?.text
            if let hexColor = viewmodel?.hexColor, let uiColor =  UIColor(hex: hexColor) {
                textView.configureTextColor(color: uiColor)
                coloPickerView.confugureColor(color: uiColor)
            } else {
                textView.textColor = ThemeColors.textViewColor
            }
                        
            deadlineView.setDeadline(date: viewmodel?.deadline)
            
            priorityView.setPriority(priority: TaskPriority(rawValue: viewmodel?.priority ?? TaskPriority.ordinary.rawValue) ?? TaskPriority.ordinary)
            if let deadline = viewmodel?.deadline {
                deadlineView.setDeadline(date: deadline)
            }
            datePicker.isHidden = true
            deleteButton.isEnabled = true
        } else {
            priorityView.setPriority(priority: .ordinary)
            deadlineView.makeLayoutForSwitcherIsOff()
            textView.setTextViewForPlaceHolder()
            coloPickerView.confugureColor(color: .white)
            cancelButton.isEnabled = true
        }
    }
    
    func configureColor(color: UIColor) {
        print(color, "color from cintroller")
        cancelButton.isEnabled = true
        saveButton.isEnabled = true
        coloPickerView.confugureColor(color: color)
        textView.configureTextColor(color: color)
    }
    
    // MARK: - Transition Methods
    func configureWithLandscape() {
        deleteButton.isHidden = true
        containerForViews.isHidden = true
        textView.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.textViewHeight).isActive = false
        textView.heightAnchor.constraint(equalToConstant: safeAreaLayoutGuide.layoutFrame.width - Layout.scrollViewInsets.top * 2 - Layout.topStackViewHeight).isActive = true
        textView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
    }
    
    func configureWithNormal() {
        deleteButton.isHidden = false
        containerForViews.isHidden = false
        textView.heightAnchor.constraint(equalToConstant: safeAreaLayoutGuide.layoutFrame.width - Layout.scrollViewInsets.top * 2).isActive = false
        textView.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.textViewHeight).isActive = true
    }
}
// MARK: - DetailTextViewDelegate
extension DetailView: DetailTextViewDelegate, UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        saveButton.isEnabled = true
        cancelButton.isEnabled = true
        deleteButton.isEnabled = true
        if textView.text == Layout.placeholderTextView {
            textView.text = ""
            let newPosition = textView.beginningOfDocument
            textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
        }
        if textView.textColor == ThemeColors.placeholderColor {
            textView.text = nil
            textView.textColor = ThemeColors.textViewColor
        }
    }
}

// MARK: - PriorityViewDelegate
extension DetailView: PriorityViewDelegate {
    func priorityDidChanged(_ priority: TaskPriority) {
        cancelButton.isEnabled = true
        saveButton.isEnabled = true
        delegate?.changePriority(to: priority)
    }
}

// MARK: - DeadlineViewDelegate
extension DetailView: DeadlineViewDelegate {
    func deadlineSwitchChanged(isOn: Bool) {
        if isOn {
            let date = Calendar.current.date(byAdding: .day, value: 1, to: .now)!
            deadlineView.makeLayoutForSwitcherIsOn(for: date)
            delegate?.addDeadline(to: Double(date.timeIntervalSince1970))
        } else {
            deadlineView.makeLayoutForSwitcherIsOff()
            delegate?.deleteDeadline()
            datePickerHide()
        }
        cancelButton.isEnabled = true
        saveButton.isEnabled = true
    }
    
    func deadlineDateButtonTapped() {
        if datePicker.isHidden {
            datePickerShow()
        } else {
            datePickerHide()
        }
    }
}
// MARK: - colorView delegate
extension DetailView: ColorViewDelegate {
    func openColorController() {
        delegate?.openColorController()
    }
}

// MARK: - Layout Constants
extension DetailView {
    private enum Layout {
        static let fontSize: CGFloat = 17
        static let backgroundcolor = ThemeColors.backPrimary
        static let topStackViewInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
        static let topStackViewHeight: CGFloat = 50
        static let topStackViewMinimumLineSpacing: CGFloat = 10
        static let cancelButtonText = "Отменить"
        static let titleLabelText = "Дело"
        static let saveButtonText = "Сохранить"
        static let deleteButtonText = "Удалить"
        static let scrollViewInsets = UIEdgeInsets(top: 17, left: 16, bottom: 0, right: -16)
        static let lineSpacing: CGFloat = 16
        static let textViewHeight: CGFloat = 120
        static let cellsHeight: CGFloat = 60
        static let cornerRadius: CGFloat = 16
        static let placeholderTextView = "Что сделать?"
    }
}
