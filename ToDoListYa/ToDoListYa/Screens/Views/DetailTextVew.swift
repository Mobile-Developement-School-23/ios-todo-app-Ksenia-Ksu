import UIKit

protocol DetailTextViewDelegate: AnyObject {
    //пока нет реализации
}

final class DetailTextView: UITextView {

    weak var textViewDelegate: DetailTextViewDelegate?

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupTextView()
        addTextViewGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTextView() {
        delegate = self
        font = UIFont.systemFont(ofSize: Layout.fontSize, weight: .regular)
        textColor = ThemeColors.textViewColor
        backgroundColor = ThemeColors.backSecondary
        layer.cornerRadius = Layout.cornerRadius
        layer.masksToBounds = true
        textContainerInset = Layout.textContainerInset
        setTextViewForPlaceHolder()
        addTextViewGesture()
    }

    private func addTextViewGesture() {
        isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(textViewTapped))
        addGestureRecognizer(gesture)
    }

    @objc private func textViewTapped() {
        becomeFirstResponder()
    }

    private func setTextViewForUserDescription() {
        tintColor = ThemeColors.textViewColor
    }

    func setTextViewForPlaceHolder() {
        text = ""
        //textColor = ThemeColors.textViewColor
        //textColor = ThemeColors.placeholderColor
        text = Layout.placeholderText
    }
}

// MARK: - TextViewDelegate

extension DetailTextView: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        if textView.text == nil || textView.text?.isEmpty == true || textView.text == Layout.placeholderText {
            textView.text = Layout.placeholderText
            let newPosition = textView.beginningOfDocument
            textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
            setTextViewForPlaceHolder()
        } else {
            setTextViewForUserDescription()
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        setTextViewForUserDescription()
        if textView.text == Layout.placeholderText {
            textView.text = ""
            let newPosition = textView.beginningOfDocument
            textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == nil || textView.text?.isEmpty == true || textView.text == Layout.placeholderText {
            textView.text = Layout.placeholderText
            setTextViewForPlaceHolder()
        } else {
            textView.text = ""
            setTextViewForUserDescription()
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text == Layout.placeholderText {
            textView.text = ""
            setTextViewForUserDescription()
    }
        return true
    }
}

//MARK: - layout constants
extension DetailTextView {
    private enum Layout {
        static let textContainerInset = UIEdgeInsets(top: 17, left: 16, bottom: 17, right: 16)
        static let cornerRadius: CGFloat = 16
        static let fontSize: CGFloat = 17
        static let textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        static let placeholderText = "Что сделать?"
        static let placeholderColor = UIColor(red: 0.82, green: 0.82, blue: 0.84, alpha: 1)
    }
}

