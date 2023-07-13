import UIKit

protocol NewTodoDelegate: AnyObject {
    func createNewTodo()
}

final class NewTodoCell: UITableViewCell {
    
    weak var newTodoDelegate: NewTodoDelegate?
    
    lazy var newTaskLabel: UILabel = {
        let newTaskLabel = UILabel()
        newTaskLabel.text = Layout.newLabelText
        newTaskLabel.font = UIFont.systemFont(ofSize: Layout.newLabelFont)
        newTaskLabel.textColor = ThemeColors.textViewColor
        newTaskLabel.translatesAutoresizingMaskIntoConstraints = false
        return newTaskLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: Layout.cellId)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectionStyle = .none
        addSubviews()
        makeConstraints()
    }
    
    private func addSubviews() {
        addSubview(newTaskLabel)
    }
    
    private func makeConstraints() {
        
        NSLayoutConstraint.activate([
            newTaskLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            newTaskLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
}

extension NewTodoCell {
    private enum Layout {
        static let cellId = "new todo cell"
        static let newLabelText = "Новое"
        static let newLabelFont: CGFloat = 17
        static let newLabelColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
    }
}
