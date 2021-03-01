//
//  MKTextViewEditor.swift
//  MKTextViewEditor
//
//  Created by Mackellen on 2021/2/25.
//

import UIKit

enum MKEditorAction {
    case none
    case bold
    case underline
    case image
    case keyboard
}

public class MKTextViewEditor: UITextView {

    var action: MKEditorAction = .none
    var isBold: Bool = false
    var isUnderline: Bool = false
    var txtColor: UIColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
    var fontSize: CGFloat = 15
    public var uploadImages:((_ image: UIImage) -> Void)?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.delegate = self
        self.textColor = txtColor
        self.isSelectable = true
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.font = UIFont.systemFont(ofSize: fontSize)
        
        self.resetTypingAttributes()
        
        let editorManager = MKTextEditorManager()
        editorManager.editorView = self
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func setBoldInRange() {
        let attributedString = self.attributedText.mutableCopy() as! NSMutableAttributedString
        attributedString.enumerateAttribute(NSAttributedString.Key.font, in: self.selectedRange, options: NSAttributedString.EnumerationOptions.longestEffectiveRangeNotRequired) {[weak self] (value, range0, stop) in
            guard let self = self else { return }
            if let value = value as? UIFont {
                let fontSize = value.fontDescriptor.fontAttributes[UIFontDescriptor.AttributeName.size] as! CGFloat
                let newFont = self.isBold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
                attributedString.addAttribute(NSAttributedString.Key.font, value: newFont, range: range0)
            }
        }
        self.attributedText = attributedString.copy() as? NSAttributedString
    }
    @objc func setUnderlineInRange() {
        let attributedString = self.attributedText.mutableCopy() as! NSMutableAttributedString
        if isUnderline == false {
            attributedString.removeAttribute(NSAttributedString.Key.underlineStyle, range: self.selectedRange)
            attributedString.removeAttribute(NSAttributedString.Key.underlineColor, range: self.selectedRange)
            self.attributedText = attributedString.copy() as? NSAttributedString
            return
        }
        attributedString.enumerateAttribute(NSAttributedString.Key.foregroundColor, in: self.selectedRange, options: NSAttributedString.EnumerationOptions.longestEffectiveRangeNotRequired) { (value, range0, stop) in
            if let value = value as? UIColor {
                attributedString.addAttribute(NSAttributedString.Key.underlineColor, value: value, range: range0)
                attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: range0)
            }
        }
        self.attributedText = attributedString.copy() as? NSAttributedString
    }
    func handleAction(newAction: MKEditorAction, value: Any?) {
        action = newAction
        var rangeSelector: Selector? = nil
        switch newAction {
        case .bold:
            guard let value = value as? Bool else { return }
            self.isBold = value
            rangeSelector = #selector(setBoldInRange)
        case .underline:
            guard let value = value as? Bool else { return }
            self.isUnderline = value
            rangeSelector = #selector(setUnderlineInRange)
        case .image:
            guard let value = value as? UIImage else { return }
            self.setImage(value)
        case .keyboard:
            self.resignFirstResponder()
            return
        case .none:
            break
        }
        if self.selectedRange.length > 0 {
            let range = self.selectedRange
            self.perform(rangeSelector)
            self.selectedRange = range
            self.scrollRangeToVisible(range)
        } else {
            self.resetTypingAttributes()
        }
    }
    func resetTypingAttributes() {
        if self.selectedRange.length == 0 {
            return
        }
        self.typingAttributes = self.currentAttributes()
    }
    func currentAttributes() ->  [NSAttributedString.Key: Any] {
        var diction = self.typingAttributes
        switch action {
        case .bold:
            let font: UIFont = diction[NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue)] as! UIFont
            let fontSize = font.fontDescriptor.fontAttributes[UIFontDescriptor.AttributeName.size] as! CGFloat
            if isBold {
                diction[NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue)] = UIFont.boldSystemFont(ofSize: fontSize)
            } else {
                diction[NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue)] = UIFont.systemFont(ofSize: fontSize)
            }
        case .underline:
            if isUnderline {
                let color = diction[NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue)]
                diction[NSAttributedString.Key(rawValue: NSAttributedString.Key.underlineColor.rawValue)] = color
                diction[NSAttributedString.Key(rawValue: NSAttributedString.Key.underlineStyle.rawValue)] = 1
            } else {
                diction.removeValue(forKey: NSAttributedString.Key(rawValue: NSAttributedString.Key.underlineColor.rawValue))
                diction.removeValue(forKey: NSAttributedString.Key(rawValue: NSAttributedString.Key.underlineStyle.rawValue))
            }
        case .image, .keyboard:
            break
        default:
            break
        }
        return diction
    }
    func setImage(_ image: UIImage?) {
        if image == nil {
            self.becomeFirstResponder()
            return
        }
        self.uploadImages?(image!)
        let width = self.frame.size.width-self.textContainer.lineFragmentPadding*2
        let mAttributedString = self.attributedText.mutableCopy() as! NSMutableAttributedString
        let attachment = NSTextAttachment()
        attachment.bounds = CGRect(x: 0, y: 0, width: width-5, height: width*(image!.size.height/image!.size.width))
        let newImage = image?.roundImage(size: attachment.bounds.size, cornerRadi: 12)
        attachment.image = newImage
        let attachmentString = NSMutableAttributedString(attachment: attachment)
        let currentDic = self.currentAttributes()
        attachmentString.addAttributes(currentDic, range: NSMakeRange(0, attachmentString.length))
        mAttributedString.insert(attachmentString, at: NSMaxRange(self.selectedRange))
        
        self.attributedText = mAttributedString.copy() as? NSAttributedString

        let location = NSMaxRange(self.selectedRange) + 1
        self.selectedRange = NSMakeRange(location, 0)
        self.becomeFirstResponder()
    }
}
extension MKTextViewEditor: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.count > 23 {
            let range = NSRange(location: 0, length: textView.text.count-1)
            let attributedString = self.attributedText.mutableCopy() as! NSMutableAttributedString
            attributedString.enumerateAttribute(NSAttributedString.Key.paragraphStyle, in: range, options: NSAttributedString.EnumerationOptions.longestEffectiveRangeNotRequired) {(value, range0, stop) in
                if  value is NSParagraphStyle {
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineSpacing = 5
                    attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range0)
                }
            }
            self.attributedText = attributedString.copy() as? NSAttributedString
        }
        return true
    }
}
