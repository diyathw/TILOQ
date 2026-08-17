import SwiftUI
import UIKit

final class KeyboardViewController: UIInputViewController {
    private var host: UIHostingController<TypeKeyboardView>?
    private var heightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        let keyboard = TypeKeyboardView(
            sourceText: { [weak self] in
                guard let proxy = self?.textDocumentProxy else { return "" }
                return proxy.selectedText ?? proxy.documentContextBeforeInput ?? ""
            },
            selectedText: { [weak self] in
                self?.textDocumentProxy.selectedText
            },
            typingContext: { [weak self] in
                self?.textDocumentProxy.documentContextBeforeInput ?? ""
            },
            onSuggestion: { [weak self] text in
                self?.textDocumentProxy.insertText(text)
            },
            onEdit: { [weak self] edit in
                self?.apply(edit)
            },
            onNextKeyboard: { [weak self] in
                self?.advanceToNextInputMode()
            },
            contextualKey: { [weak self] in self?.contextualKey },
            returnKeyLabel: { [weak self] in self?.returnKeyLabel ?? "return" },
            onPreferredHeightChange: { [weak self] height in
                self?.updateHeight(to: height)
            }
        )

        let host = UIHostingController(rootView: keyboard)
        host.view.backgroundColor = .black
        addChild(host)
        view.addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        let heightConstraint = view.heightAnchor.constraint(
            equalToConstant: KeyboardBehavior.preferredHeight(
                isResultVisible: false,
                includesNumberRow: true
            )
        )
        heightConstraint.priority = UILayoutPriority(999)
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            heightConstraint
        ])
        host.didMove(toParent: self)
        self.host = host
        self.heightConstraint = heightConstraint
    }

    override func textWillChange(_ textInput: (any UITextInput)?) {
        super.textWillChange(textInput)
    }

    override func textDidChange(_ textInput: (any UITextInput)?) {
        super.textDidChange(textInput)
        NotificationCenter.default.post(name: .tiloqKeyboardContextDidChange, object: nil)
        host?.view.setNeedsLayout()
    }

    private func apply(_ edit: KeyboardEdit) {
        switch edit {
        case .insert(let text):
            textDocumentProxy.insertText(text)
        case .deleteBackward:
            textDocumentProxy.deleteBackward()
        case .moveCursor(let offset):
            textDocumentProxy.adjustTextPosition(byCharacterOffset: offset)
        case .replaceBeforeCursor(let original, let replacement):
            if textDocumentProxy.selectedText != nil {
                textDocumentProxy.insertText(replacement)
                return
            }
            guard textDocumentProxy.documentContextBeforeInput?.hasSuffix(original) == true else {
                return
            }
            original.forEach { _ in textDocumentProxy.deleteBackward() }
            textDocumentProxy.insertText(replacement)
        }
    }

    private func updateHeight(to height: CGFloat) {
        guard let heightConstraint,
              abs(heightConstraint.constant - height) > 0.5 else { return }

        heightConstraint.constant = height
        preferredContentSize.height = height
        view.superview?.setNeedsLayout()
        UIView.animate(
            withDuration: 0.22,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseInOut]
        ) {
            self.view.superview?.layoutIfNeeded()
        }
    }

    private var contextualKey: String? {
        switch textDocumentProxy.keyboardType {
        case .emailAddress:
            "@"
        case .URL:
            ".com"
        default:
            nil
        }
    }

    private var returnKeyLabel: String {
        switch textDocumentProxy.returnKeyType {
        case .done: "done"
        case .go: "go"
        case .join: "join"
        case .next: "next"
        case .search: "search"
        case .send: "send"
        case .continue: "continue"
        default: "return"
        }
    }
}
