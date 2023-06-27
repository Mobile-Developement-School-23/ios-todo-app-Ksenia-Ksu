import UIKit

protocol DeadlineViewDelegate: AnyObject {
    func deadlineSwitchChanged(isOn: Bool)
    func deadlineDateButtonTapped()
}

final class DeadlineView: UIView {
    
    weak var deadlineViewDelegate: DeadlineViewDelegate?
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var deadlineLabel: UILabel = {
        let deadlineLabel = UILabel()
        deadlineLabel.text = Layout.text
        deadlineLabel.font = UIFont.systemFont(ofSize: Layout.fontSize, weight: .regular)
        deadlineLabel.translatesAutoresizingMaskIntoConstraints = false
        return deadlineLabel
    }()
    
    lazy var dateButton: UIButton = {
        let dateButton = UIButton()
        dateButton.setTitleColor(.systemBlue, for: .normal)
        dateButton.titleLabel?.font = UIFont.systemFont(ofSize: Layout.littleFontSize, weight: .regular)
        dateButton.isHidden = true
        dateButton.translatesAutoresizingMaskIntoConstraints = false
        dateButton.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
        return dateButton
    }()
    
    lazy var switcher: UISwitch = {
        let switcher = UISwitch()
        return switcher
    }()
    
    private lazy var separatorView: UIView = {
        let separatorView = UIView()
        separatorView.backgroundColor = ThemeColors.separatorColor
        separatorView.isHidden = true
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        return separatorView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = ThemeColors.backSecondary
        switcher.translatesAutoresizingMaskIntoConstraints = false
        switcher.addTarget(self, action: #selector(switcherChanged(sender:)), for: .valueChanged)
        
        addSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(switcher)
        addSubview(stackView)
        stackView.addArrangedSubview(deadlineLabel)
        stackView.addArrangedSubview(dateButton)
        addSubview(separatorView)
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.stackViewInsets.left),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            switcher.centerYAnchor.constraint(equalTo: centerYAnchor),
            switcher.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Layout.trailingInset),
            
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.lineInsets.left),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Layout.lineInsets.right),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: Layout.height)
        ])
    }
    
    func dateChosen(_ date: Date) {
        let dateString = date.stringFromDate()
        dateButton.setTitle(dateString, for: .normal)
    }
    
    func makeLayoutForSwitcherIsOn(for date: Date) {
        dateButton.isHidden = false
        dateChosen(date)
    }
    
    func makeLayoutForSwitcherIsOff() {
        dateButton.isHidden = true
        dateButton.setTitle(nil, for: .normal)
        switcher.isOn = false
    }
    
    @objc func dateButtonTapped() {
        controlSeparatorView()
        deadlineViewDelegate?.deadlineDateButtonTapped()
    }
    
    @objc func switcherChanged(sender: UISwitch) {
        deadlineViewDelegate?.deadlineSwitchChanged(isOn: sender.isOn)
    }
    
    func setDeadline(date: Double?) {
        if date != nil {
            switcher.isOn = true
            dateButton.setTitle(date!.timeInSecondsToDateString(), for: .normal)
            dateButton.isHidden = false
        } else {
           makeLayoutForSwitcherIsOff()
        }
    }
    
    func controlSeparatorView() {
        if separatorView.isHidden {
            separatorView.isHidden = false
        } else {
            separatorView.isHidden = true
        }
    }
}

extension DeadlineView {
    private enum Layout {
        static let text = "Сделать до"
        static let fontSize: CGFloat = 17
        static let littleFontSize: CGFloat = 15
        static let stackViewInsets = UIEdgeInsets(top: 16, left: 16, bottom: -16, right: 0)
        static let trailingInset: CGFloat = -16
        static let height: CGFloat = 0.5
        static let lineInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
    
    }
}
