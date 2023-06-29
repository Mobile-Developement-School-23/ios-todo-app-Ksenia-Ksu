import UIKit

protocol HeaderViewDelegate: AnyObject {
    func showButtonTapped()
}

final class HeaderViewCell: UITableViewCell {
    
    weak var headerViewDelegate: HeaderViewDelegate?
    
    lazy var doneLabel: UILabel = {
        let label = UILabel()
        label.text = Layout.doneLabelText
        label.font = UIFont.systemFont(ofSize: Layout.labelsFont)
        label.textColor = Layout.doneLabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var showButton: UIButton = {
        let showButton = UIButton(configuration: .plain())
        showButton.setTitle(Layout.showButtonText, for: .normal)
        showButton.setTitleColor(.systemBlue, for: .normal)
        showButton.setTitleColor(.systemGray2, for: .disabled)
        showButton.titleLabel?.font = UIFont.systemFont(ofSize: Layout.labelsFont, weight: .bold)
        showButton.translatesAutoresizingMaskIntoConstraints = false
        return showButton
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: Layout.cellId)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .clear
        selectionStyle = .none
        addSubviews()
        makeConstraints()
    }
    
    private func addSubviews() {
        addSubview(doneLabel)
        addSubview(showButton)
    }
    
    private func makeConstraints() {
        
        NSLayoutConstraint.activate([
            doneLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.insets.left),
            doneLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            showButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Layout.insets.right),
            showButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    func configureDoneTasks(with count: Int) {
        doneLabel.text = "Выполнено - \(count)"
    }
}

extension HeaderViewCell {
    private enum Layout {
        static let cellId = "header cell"
        static let doneLabelText = "Выполнено - 0"
        static let labelsFont: CGFloat = 17
        static let doneLabelColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
        static let showButtonText = "Показать"
        static let insets = UIEdgeInsets(top: 5, left: 16, bottom: 8, right: -16)
    }
}
