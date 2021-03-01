//
//  MKTextEditorManager.swift
//  MKTextViewEditor
//
//  Created by Mackellen on 2021/2/25.
//

import UIKit

class MKTextEditorManager: NSObject {
    
    var toolBar: MKTextEditorToolBar = {
        let toolBar = MKTextEditorToolBar()
        toolBar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        return toolBar
    }()

    var editorView: MKTextViewEditor? {
        didSet {
            editorView?.inputAccessoryView = self.toolBar
            self.addKeyboardNotifications()
            self.toolBar.itemClickBlock = {(action, value) in
                self.editorView?.handleAction(newAction: action, value: value)
            }
        }
    }
    var editable: Bool = false
    var editorInsetsBottom: CGFloat = 0
    
    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowOrHide), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowOrHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShowOrHide(notific: Notification) {
        let info = notific.userInfo
        let duration = info?[UIResponder.keyboardAnimationDurationUserInfoKey] as! CGFloat
        let curve: UInt = info?[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let keyboardEnd: CGRect = info?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect

        var keyboardHeight: CGFloat = 0
        if UIDevice.current.orientation.isLandscape {
            keyboardHeight = Float(UIDevice.current.systemVersion)! >= 8.00 ? keyboardEnd.size.height : keyboardEnd.size.width
        } else {
            keyboardHeight = keyboardEnd.size.height
        }
        let animationOptions = UIView.AnimationOptions(rawValue: (curve << 16))
        let extraHeight: CGFloat = 20
        if notific.name == UIResponder.keyboardWillShowNotification {
            UIView.animate(withDuration: TimeInterval(duration), delay: 0, options: animationOptions) {
                var insets = self.editorView?.contentInset
                insets?.bottom = keyboardHeight + extraHeight + self.editorInsetsBottom
                self.editorView?.contentInset = insets ?? UIEdgeInsets()
            } completion: { (_) in
            }
        } else {
            UIView.animate(withDuration: TimeInterval(duration), delay: 0, options: animationOptions) {
                var insets = self.editorView?.contentInset
                insets?.bottom = self.editorInsetsBottom
                self.editorView?.contentInset = insets ?? UIEdgeInsets()
            } completion: { (_) in
            }
        }
    }
    deinit {
        self.removeKeyboardNotifications()
    }
}

