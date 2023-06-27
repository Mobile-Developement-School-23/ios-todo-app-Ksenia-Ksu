import UIKit


protocol PriorityViewDelegate: AnyObject {
    func priorityDidChanged(_ priority: TaskPriority)
}

final class PriorityView: UIView {
    
    weak var priorityVewDelegate: PriorityViewDelegate?
    
    private lazy var priorityLabel: UILabel = {
        let label = UILabel()
        label.text = Layout.text
        label.font = UIFont.systemFont(ofSize: Layout.fontSize, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var segmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: ["low", "normal", "high"])
        segmentControl.setImage(Layout.lowImage?.withRenderingMode(.alwaysOriginal), forSegmentAt: 0)
        segmentControl.setTitle("нет", forSegmentAt: 1)
        segmentControl.setImage(Layout.highImage?.withRenderingMode(.alwaysOriginal), forSegmentAt: 2)
        
        segmentControl.setWidth(Layout.segmentControlWidth, forSegmentAt: 0)
        segmentControl.setWidth(Layout.segmentControlWidth, forSegmentAt: 1)
        segmentControl.setWidth(Layout.segmentControlWidth, forSegmentAt: 2)
        
        let font: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: Layout.segmentControlFontSize)]
        segmentControl.setTitleTextAttributes(font, for: .normal)
        segmentControl.backgroundColor = ThemeColors.backSegmentedControl
        
        segmentControl.addTarget(self, action: #selector(segmentControlTapped(sender:)), for: .valueChanged)
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentControl
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
        addSubview(priorityLabel)
        addSubview(segmentControl)
        addSubview(separatorView)
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            priorityLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            priorityLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.leadingInset),
            
            segmentControl.topAnchor.constraint(equalTo: topAnchor, constant: Layout.segmentControlInsets.top),
            segmentControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Layout.segmentControlInsets.right),
            
            segmentControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Layout.segmentControlInsets.bottom),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: Layout.height),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.lineInsets.left),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Layout.lineInsets.right)
        ])
    }
    
    
    @objc func segmentControlTapped(sender: UISegmentedControl) {
        var taskPriority = TaskPriority.ordinary
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            taskPriority = .unimportant
        case 1:
            taskPriority = .ordinary
        case 2:
            taskPriority = .important
        default:
            taskPriority = .ordinary
        }
        priorityVewDelegate?.priorityDidChanged(taskPriority)
    }
    
    func setPriority(priority: TaskPriority) {
        switch priority {
        case .unimportant:
            segmentControl.selectedSegmentIndex = 0
        case .ordinary:
            segmentControl.selectedSegmentIndex = 1
        case .important:
            segmentControl.selectedSegmentIndex = 2
        }
    }
}

extension PriorityView {
    private enum Layout {
        static let leadingInset: CGFloat = 16
        static let text = "Важность"
        static let fontSize: CGFloat = 17
        static let segmentControlInsets = UIEdgeInsets(top: 13, left: 0, bottom: -13, right: -16)
        static let segmentControlWidth: CGFloat = 48
        static let segmentControlFontSize: CGFloat = 15
        static let height: CGFloat = 0.5
        static let lineInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        static let lowImage = UIImage(named: "low")
        static let highImage = UIImage(named: "high")
    }
}
