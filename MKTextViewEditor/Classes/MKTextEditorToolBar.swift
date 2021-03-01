//
//  MKTextEditorToolBar.swift
//  MKTextViewEditor
//
//  Created by Mackellen on 2021/2/25.
//

import UIKit

class MKTextEditorToolBar: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var itemClickBlock: ((_ action: MKEditorAction, _ value: Any?) -> ())?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        self.setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupSubviews() {
        self.addSubview(rootView)
        rootView.addSubview(stackView)
        stackView.addArrangedSubview(boldButton)
        stackView.addArrangedSubview(underlineButton)
        stackView.addArrangedSubview(imageButton)
        rootView.addSubview(keyboardButton)
    }

    @objc func clickButtonWith(_ button: UIButton) {
        button.isSelected = !button.isSelected
        switch button.tag {
        case 1:
            self.itemClickBlock?(.bold, button.isSelected)
        case 2:
            self.itemClickBlock?(.underline, button.isSelected)
        case 3:
            self.showImagePicker()
        case 4:
            self.itemClickBlock?(.keyboard, false)
        default:
            break
        }
    }

    func showImagePicker() {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .photoLibrary
        pickerController.allowsEditing = true
        pickerController.delegate = self

        let rootController = UIApplication.shared.windows.filter{ $0.isKeyWindow }.first?.rootViewController
        rootController?.present(pickerController, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image: UIImage?
        if picker.allowsEditing {
            guard let selectedImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.editedImage.rawValue)] as? UIImage else {
                fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
            }
            image = selectedImage
        } else {
            guard let selectedImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage else {
                fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
            }
            image = selectedImage
        }
        picker.dismiss(animated: true) {
            self.itemClickBlock?(.image, image)
            self.imageButton.isSelected = false
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.itemClickBlock?(.image, nil)
            self.imageButton.isSelected = false
        }
    }

    lazy var rootView: UIView = {
       let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        return view
    }()
    lazy var stackView: UIStackView = {
        let stackview = UIStackView()
        stackview.distribution = .fillEqually
        stackview.frame = CGRect(x: 0, y: 0, width: 132, height: 40)
        return stackview
    }()
    lazy var boldButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 40)
        let image = UIImage(named: "pic-bold")
        button.setImage(image, for: .normal)
        let imageSelected = UIImage(named: "pic-bold-selected")
        button.setImage(imageSelected, for: .selected)
        button.tag = 1
        button.addTarget(self, action: #selector(clickButtonWith), for: .touchUpInside)
        return button
    }()
    lazy var underlineButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 40)
        let image = UIImage(named: "pic-under")
        button.setImage(image, for: .normal)
        let imageSelected = UIImage(named: "pic-under-selected")
        button.setImage(imageSelected, for: .selected)
        button.tag = 2
        button.addTarget(self, action: #selector(clickButtonWith), for: .touchUpInside)
        return button
    }()
    lazy var imageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 40)
        let image = UIImage(named: "pic-lib")
        button.setImage(image, for: .normal)
        let imageSelected = UIImage(named: "pic-lib-selected")
        button.setImage(imageSelected, for: .selected)
        button.tag = 3
        button.addTarget(self, action: #selector(clickButtonWith), for: .touchUpInside)
        return button
    }()
    lazy var keyboardButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 40)
        let image = UIImage(named: "pic-keyborad")
        button.frame = CGRect(x: UIScreen.main.bounds.width-54, y: 0, width: 44, height: 44)
        button.setImage(image, for: .normal)
        button.tag = 4
        button.addTarget(self, action: #selector(clickButtonWith), for: .touchUpInside)
        return button
    }()
}
