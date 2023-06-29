import UIKit

protocol ToDoListTableViewCellDelegate: AnyObject {
    func taskDoneButtonTapped()
}

final class ToDoListTableViewCell: UITableViewCell {
    
    weak var todoCellDelagate: ToDoListTableViewCellDelegate?
    
    lazy var checkButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = Layout.noCheckmark
        let checkButton = UIButton(configuration: config)
        checkButton.addTarget(self, action: #selector(checkButtonTapped(sender:)), for: .touchUpInside)
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        return checkButton
    }()
    
    private lazy var containerStack: UIStackView = {
        let containerStack = UIStackView()
        containerStack.axis = .horizontal
        containerStack.alignment = .center
        containerStack.spacing = 5
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        return containerStack
    }()
    
    lazy var priorityView: UIImageView = {
        let priorityView = UIImageView()
        priorityView.isHidden = true
        priorityView.contentMode = .scaleAspectFit
        priorityView.translatesAutoresizingMaskIntoConstraints = false
        return priorityView
    }()
    
    lazy var stackVertical: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 3
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var itemlabel: UILabel = {
        let itemlabel = UILabel()
        itemlabel.text = "Taskonkkkkkkkkkkkkkkkkkknbhbbhhbhhbbhhbhkfkfkfkfkfkfkkfkfkfkkfkfkfkfkkfkfkfkfkkfkfkfkkfkfkfkfkkfkfkfkkfkfkfkfkkfkfkkfkfkfkkfkfkkfkfkfkfkfkfkkfbhbhbhbbhhbhbhbbh"
        itemlabel.font = UIFont.systemFont(ofSize: Layout.taskFont)
        itemlabel.numberOfLines = 3
        itemlabel.translatesAutoresizingMaskIntoConstraints = false
        return itemlabel
    }()
    
    lazy var stackDeadline: UIStackView = {
        let stackDeadline = UIStackView()
        stackDeadline.axis = .horizontal
        stackDeadline.spacing = 2
        stackDeadline.translatesAutoresizingMaskIntoConstraints = false
        return stackDeadline
    }()
    
    lazy var deadlineLabel: UILabel = {
        let deadlineLabel = UILabel()
        deadlineLabel.text = "deadline"
        deadlineLabel.isHidden = true
        deadlineLabel.font = UIFont.systemFont(ofSize: Layout.deadlineFont)
        deadlineLabel.textColor = ThemeColors.placeholderColor
        deadlineLabel.translatesAutoresizingMaskIntoConstraints = false
        return deadlineLabel
    }()
    
    lazy var deadlineImage: UIImageView = {
        let deadlineImage = UIImageView()
        deadlineImage.image = Layout.calendar
        deadlineImage.isHidden = true
        deadlineImage.translatesAutoresizingMaskIntoConstraints = false
        return deadlineImage
    }()
    
    lazy var chevronImage: UIImageView = {
        let chevronImage = UIImageView()
        chevronImage.image = Layout.chevron
        chevronImage.translatesAutoresizingMaskIntoConstraints = false
        return chevronImage
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: Layout.cellId)
        addSubviews()
        makeConstraints()
    }
    
    private func addSubviews() {
        addSubview(checkButton)
        addSubview(containerStack)
        addSubview(chevronImage)
        containerStack.addArrangedSubview(priorityView)
        containerStack.addArrangedSubview(stackVertical)
        stackVertical.addArrangedSubview(itemlabel)
        stackVertical.addArrangedSubview(stackDeadline)
        stackDeadline.addArrangedSubview(deadlineImage)
        stackDeadline.addArrangedSubview(deadlineLabel)
      
    }
    
    private func makeConstraints() {
        
        NSLayoutConstraint.activate([
            
            checkButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.inset),
            checkButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkButton.widthAnchor.constraint(equalToConstant: Layout.checkButtonSize),
            checkButton.heightAnchor.constraint(equalToConstant: Layout.checkButtonSize),
           
            containerStack.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: Layout.inset/2),
            containerStack.trailingAnchor.constraint(equalTo: chevronImage.leadingAnchor, constant: -Layout.inset),
            containerStack.topAnchor.constraint(equalTo: topAnchor, constant: Layout.inset),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.inset),
            
            priorityView.widthAnchor.constraint(equalToConstant: Layout.prioritySize),
            priorityView.heightAnchor.constraint(equalToConstant: Layout.prioritySize),
            
            deadlineImage.heightAnchor.constraint(equalToConstant: 15),
            deadlineImage.widthAnchor.constraint(equalToConstant: 15),
        
            chevronImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.inset),
            chevronImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronImage.widthAnchor.constraint(equalToConstant: Layout.chevronWidth),
            chevronImage.heightAnchor.constraint(equalToConstant: Layout.chevronHeigth)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func checkButtonTapped(sender: UIButton) {
        if checkButton.imageView?.image == Layout.greenCheckmark {
            checkButton.imageView?.image = Layout.noCheckmark
        } else if checkButton.imageView?.image == Layout.redCheck {
            checkButton.imageView?.image = Layout.greenCheckmark
        }
    }
    
    // MARK: - CellConfiguration
    
    func configureToDoCell(with viewModel: ToDoViewModel) {
        configurePriority(with: viewModel)
        configureCheckButton(with: viewModel)
        configureDeadline(with: viewModel)
        configureText(with: viewModel)
    }
    
    private func configureText(with viewModel: ToDoViewModel) {
        if viewModel.taskDone {
            itemlabel.textColor = Layout.taskDoneTextColor
            let attributedText = NSMutableAttributedString(string: viewModel.title)
            attributedText.addAttribute(.strikethroughStyle, value: 1, range: NSRange(location: 0, length: attributedText.length))
            itemlabel.attributedText = attributedText
        }
    }
    
    private func configureCheckButton(with viewModel: ToDoViewModel) {
        if viewModel.taskDone {
            checkButton.setImage(Layout.greenCheckmark, for: .normal)
        } else if !viewModel.taskDone && viewModel.priority == .important {
            checkButton.setImage(Layout.redCheck, for: .normal)
        } else {
            #warning("add tintcolor for black theme")
            checkButton.setImage(Layout.noCheckmark, for: .normal)
        }
       
    }
    
    private func configurePriority(with viewModel: ToDoViewModel) {
        switch viewModel.priority {
        case .important:
            priorityView.isHidden = false
            priorityView.image = Layout.highImage
        case .ordinary:
            priorityView.isHidden = true
        case .unimportant:
            priorityView.isHidden = false
            priorityView.image = Layout.lowImage
        }
    }
    
    private func configureDeadline(with viewModel: ToDoViewModel) {
        if viewModel.deadline != nil {
            deadlineLabel.text = viewModel.deadline
            deadlineImage.isHidden = false
            deadlineLabel.isHidden = false
        } else {
            deadlineLabel.isHidden = true
            deadlineImage.isHidden = true
        }
    }
}

extension ToDoListTableViewCell {
    private enum Layout {
        static let greenCheckmark = UIImage(named: "propGreenCheckmark")
        static let noCheckmark = UIImage(named: "propOff")
        static let redCheck = UIImage(named: "propHighPriority")
        static let checkButtonSize: CGFloat = 30
        static let lowImage = UIImage(named: "low")
        static let highImage = UIImage(named: "high")
        static let calendar = UIImage(named: "calendar")
        static let chevron = UIImage(named: "arrowRight")
        static let prioritySize: CGFloat = 15
        static let chevronWidth: CGFloat = 6
        static let chevronHeigth: CGFloat = 12
        static let cellId = "Cell"
        static let taskFont: CGFloat = 17
        static let deadlineFont: CGFloat = 15
        static let inset: CGFloat = 16
        static let taskDoneTextColor = UIColor(red: 0.56, green: 0.56, blue: 0.58, alpha: 1.00)
    }
}
