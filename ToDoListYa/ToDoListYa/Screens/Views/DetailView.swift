import UIKit


protocol DisplayDetailView: UIView {
    func configure(with viewmodel: TodoItem?)
}

protocol DetailViewDelegate: AnyObject {
    func saveItem(with text: String)
    func deleteItem()
    func cancelChanges()
    func changePriority(to priority: TaskPriority)
    func addDeadline(to newDeadline: Double)
    func deleteDeadline()
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
        cancelButton.isEnabled = false
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
        containerForViews.addArrangedSubview(priorityView)
        containerForViews.addArrangedSubview(deadlineView)
        containerForViews.addArrangedSubview(datePicker)
        mainStackView.addArrangedSubview(deleteButton)
    }
    //MARK: - Constraits
    private func makeConstraits() {
        NSLayoutConstraint.activate([
            
            topStackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0),
            topStackView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            topStackView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            
            scrollView.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: Layout.scrollViewInsets.top),
            scrollView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor,
                                                constant: Layout.scrollViewInsets.left),
            scrollView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor,
                                                 constant: Layout.scrollViewInsets.right),
            scrollView.bottomAnchor.constraint(equalTo: self.keyboardLayoutGuide.topAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            mainStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.textViewHeight),
            priorityView.heightAnchor.constraint(equalToConstant: Layout.cellsHeight),
            deadlineView.heightAnchor.constraint(equalToConstant: Layout.cellsHeight),
            
            deleteButton.heightAnchor.constraint(equalToConstant: Layout.cellsHeight),
        ])
    }
    //MARK: - Actions
    @objc func cancelButtonTapped() {
        textView.setTextViewForPlaceHolder()
        changeSaveAndCancelButtons()
        delegate?.cancelChanges()
    }
    
    @objc func saveButtonTapped() {
        if let text = textView.text {
            delegate?.saveItem(with: text)
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
    
    private func changeSaveAndCancelButtons() {
        if saveButton.isEnabled == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
        if cancelButton.isEnabled == false {
            cancelButton.isEnabled = true
        } else {
            cancelButton.isEnabled = false
        }
    }
    
    private func changeDeleteButtonState() {
        if deleteButton.isEnabled == false {
            deleteButton.isEnabled = true
        } else {
            deleteButton.isEnabled = false
        }
    }
    
}
//MARK: - DisplayDetailView
extension DetailView: DisplayDetailView {
    func configure(with viewmodel: TodoItem?) {
        if viewmodel == viewmodel {
            textView.text = viewmodel?.text
            textView.textColor = ThemeColors.textViewColor
            deadlineView.setDeadline(date: viewmodel?.deadline)
            priorityView.setPriority(priority: TaskPriority(rawValue: viewmodel?.priority ?? TaskPriority.ordinary.rawValue) ?? TaskPriority.ordinary)
            if let deadline = viewmodel?.deadline {
                deadlineView.setDeadline(date: deadline)
            }
            datePicker.isHidden = true
        } else {
            priorityView.setPriority(priority: .ordinary)
            deadlineView.setUpViewForNewTask()
            textView.setTextViewForPlaceHolder()
        }
    }
}
//MARK: - DetailTextViewDelegate
extension DetailView: DetailTextViewDelegate, UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        changeSaveAndCancelButtons()
    }
    
}

//MARK: - PriorityViewDelegate
extension DetailView: PriorityViewDelegate {
    func priorityDidChanged(_ priority: TaskPriority) {
        print("priorityChanged")
        changeSaveAndCancelButtons()
        changeDeleteButtonState()
        delegate?.changePriority(to: priority)
    }
}

//MARK: - DeadlineViewDelegate
extension DetailView: DeadlineViewDelegate {
    func deadlineSwitchChanged(isOn: Bool) {
        if isOn {
            let date = Calendar.current.date(byAdding: .day, value: 1, to: .now)!
            deadlineView.makeLayoutForSwitcherIsOn(for: date)
            delegate?.addDeadline(to: Double(date.timeIntervalSince1970))
            changeSaveAndCancelButtons()
            changeDeleteButtonState()
        } else {
            deadlineView.makeLayoutForSwitcherIsOff()
            changeSaveAndCancelButtons()
            changeDeleteButtonState()
            delegate?.deleteDeadline()
            datePickerHide()
        }
    }
    
    func deadlineDateButtonTapped() {
        if datePicker.isHidden {
            datePickerShow()
        } else {
            datePickerHide()
        }
    }
}


//MARK: - Layout Constants

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
    }
}
