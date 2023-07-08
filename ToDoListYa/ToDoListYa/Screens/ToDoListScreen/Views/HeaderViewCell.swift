import UIKit

protocol HeaderViewDelegate: AnyObject {
    func showDoneTasks()
}

final class HeaderViewCell: UITableViewCell {
    
    weak var headerViewDelegate: HeaderViewDelegate?
    
    lazy var doneLabel: UILabel = {
        let label = UILabel()
        label.text = Layout.doneLabelText
        label.font = UIFont.systemFont(ofSize: Layout.labelsFont)
        label.textColor = ThemeColors.doneTasksColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var showButton: UIButton = {
        let showButton = UIButton()
        showButton.setTitle(Layout.showButtonText, for: .normal)
        showButton.setTitleColor(.systemBlue, for: .normal)
        showButton.setTitleColor(.systemGray2, for: .disabled)
        showButton.titleLabel?.font = UIFont.systemFont(ofSize: Layout.labelsFont, weight: .bold)
        showButton.addTarget(self, action: #selector(showButtonTapped), for: .touchUpInside)
        showButton.translatesAutoresizingMaskIntoConstraints = false
        return showButton
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: Layout.cellId)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.isUserInteractionEnabled = true
        addSubviews()
        makeConstraints()
    }
    
    private func addSubviews() {
        contentView.addSubview(doneLabel)
        contentView.addSubview(showButton)
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            doneLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.insets.left),
            doneLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            showButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Layout.insets.right),
            showButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    func configureDoneTasks(with count: Int) {
        doneLabel.text = "Выполнено - \(count)"
    }
    
    @objc func showButtonTapped() {
        if showButton.titleLabel?.text == Layout.showButtonText {
            showButton.setTitle(Layout.hideButtonText, for: .normal)
        } else {
            showButton.setTitle(Layout.showButtonText, for: .normal)
        }
        headerViewDelegate?.showDoneTasks()
    }
}

extension HeaderViewCell {
    private enum Layout {
        static let cellId = "header cell"
        static let doneLabelText = "Выполнено - 0"
        static let labelsFont: CGFloat = 17
        static let showButtonText = "Показать"
        static let hideButtonText = "Скрыть"
        static let insets = UIEdgeInsets(top: 5, left: 16, bottom: 8, right: -16)
    }
}
