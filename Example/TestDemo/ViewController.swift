//
//  ViewController.swift
//  TestDemo
//
//  Created by Mackellen on 2021/3/1.
//

import UIKit
import MKTextViewEditor

class ViewController: UIViewController {
    var newHtml = """
    <span style="color:#3355443; font-size:15px;">这些是为了我们彼此之间最美好状态</span>
    <img src='https://pics3.baidu.com/feed/f11f3a292df5e0fee23232132be52ca05edf7203.jpeg?token=73390455adbdf6c85c94707cf7d7fec2&s=1241B144BB78A0DE005769100300709A' />
    <span><br /></span>
    <span style="color:#3355443; font-size:15px;">这种行为让自己更加了解他之后又有多少次我就能发现这个问题你怎么那么喜欢的一</span>
    <img src='https://pics6.baidu.com/feed/0bd162d9f2d3572cd350c85c61457a2f63d0c35b.jpeg?token=795099d8464ac7d5c2f04a21361f5aeb&s=63325CCB66134FD01420E663030000D7' />
    <span><br /></span>
    <span style="color:#3355443; font-size:15px;">在这些新技术的推动下，全社会都面临一次数字化转型的新机遇。据预测，到2025年，全球97%的大企业会部署人工智能，中国GDP的55%将由数字经济来驱动，运营商60%的收入将来自行业。如何利用技术赋能行业、打造生态至关重要。</span>
    """
    var imagePaths: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "图文编辑器"
        self.view.backgroundColor = UIColor.white
        textViewEditor.frame = CGRect(x: 8, y: 0, width: UIScreen.main.bounds.width-20, height: UIScreen.main.bounds.height)
        self.view.addSubview(textViewEditor)
        textViewEditor.uploadImages = {[weak self] (image) in
            guard let self = self else { return }
            self.imagePaths.append("https://pics4.baidu.com/feed/342ac65c1038534343252a626815a776cb80889e.png?token=22729c5fee637277071c029b4f3797e5&s=51E007E34AB38BDA0A6425870300F0C3")
        }
        if #available(iOS 11.0, *) {
            self.textViewEditor.contentInsetAdjustmentBehavior = .automatic
        }
        self.reloadData()
        let button1 = UIButton(type: .custom)
        button1.setTitle("Code", for: .normal)
        button1.setTitleColor(UIColor.darkGray, for: .normal)
        button1.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button1.addTarget(self, action: #selector(showSource), for: .touchUpInside)
        let buttonItem1 = UIBarButtonItem(customView: button1)
        
        let button2 = UIButton(type: .custom)
        button2.setTitle("Html", for: .normal)
        button2.setTitleColor(UIColor.blue, for: .normal)
        button2.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button2.addTarget(self, action: #selector(parserHtml), for: .touchUpInside)
        let buttonItem2 = UIBarButtonItem(customView: button2)
        self.navigationItem.rightBarButtonItems = [buttonItem1, buttonItem2]
        // Do any additional setup after loading the view.
    }
    func reloadData() {
        self.textViewEditor.resignFirstResponder()
    }
    @objc func parserHtml() {
        MKTextEditorHtmlParser.htmlStringWithAttributes(attributeText: self.textViewEditor.attributedText, images: self.imagePaths) { (newHtml) in
            print("newHtml---->\(newHtml)")
            self.textViewEditor.text = newHtml
        }
    }
    @objc func showSource() {
        MKTextEditorHtmlParser.attributesWithHtmlString(htmlString: self.newHtml, imageWidth: self.textViewEditor.frame.size.width) { (attributedText) in
//            print("attributedText--->\(attributedText)")
            self.textViewEditor.attributedText = attributedText
        }
    }

    lazy var textViewEditor: MKTextViewEditor = {
        let textView = MKTextViewEditor()
        textView.isEditable = true
        return textView
    }()
}

