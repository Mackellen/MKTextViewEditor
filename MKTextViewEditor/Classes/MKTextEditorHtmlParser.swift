//
//  MKTextEditorHtmlParser.swift
//  MKTextViewEditor
//
//  Created by Mackellen on 2021/2/25.
//

import UIKit
import Foundation

public class MKTextEditorHtmlParser: NSObject {
    struct Metric {
        static let imagePlaceholder = "\u{fffc}"
        static let textColor = "#333333"
    }

    public class func htmlStringWithAttributes(attributeText: NSAttributedString, images: [String], handler:((_ newHtml: String) -> Void)?) {
        DispatchQueue.global(qos: .default).async(execute: {
            let newHtmlString = self.htmlStringWithAttributeText(attributeText, images)
            DispatchQueue.main.async(execute: {
                handler?(newHtmlString)
            })
        })
    }
    class func htmlStringWithAttributeText(_ attributeText: NSAttributedString, _ imageUrls: [String]) -> String {
        if attributeText.length == 0 { return "" }
        let string = attributeText.string
        var images:[UIImage] = []
        let newHtml = NSMutableString()
        attributeText.enumerateAttributes(in: NSRange(location: 0, length: attributeText.length), options: NSAttributedString.EnumerationOptions.longestEffectiveRangeNotRequired) { (attribute, range, stop) in
            let selectedString = (string as NSString).substring(with: range)
            if selectedString == Metric.imagePlaceholder {
                let attachment: NSTextAttachment = attribute[NSAttributedString.Key.attachment] as! NSTextAttachment
                if attachment.image != nil {
                    newHtml.appendFormat("<img src='[image%ld]' />", images.count)
                    newHtml.append("<span><br /></span>")
                    images.append(attachment.image!)
                }
            } else if selectedString == "\n" {
                newHtml.append(selectedString)
            } else {
                let font: UIFont = attribute[NSAttributedString.Key.font] as! UIFont
                let textColor = Metric.textColor
                let fontSize: CGFloat = font.fontDescriptor.fontAttributes[UIFontDescriptor.AttributeName.size] as! CGFloat
                let location = newHtml.length
                newHtml.appendFormat("<span style=\"color:%@; font-size:%.0fpx;\">%@</span>", textColor,fontSize, selectedString)
                if attribute.keys .contains(NSAttributedString.Key.underlineColor) {
                    newHtml.insert("<u>", at: location)
                    newHtml.append("</u>")
                }
                if (font.fontDescriptor.symbolicTraits.rawValue & UIFontDescriptor.SymbolicTraits.traitBold.rawValue) > 0 {
                    newHtml.insert("<b>", at: location)
                    newHtml.append("</b>")
                }
            }
        }
        
        for (index, imgPath) in imageUrls.enumerated() {
            let options = NSString.CompareOptions.backwards
            newHtml.replaceOccurrences(of: "[image\(index)]", with: imgPath, options: options, range: NSRange(location: 0, length: newHtml.length))
        }
        
        return newHtml.description
    }
   public class func attributesWithHtmlString(htmlString: String, imageWidth: CGFloat, handler:((_ attributedString: NSAttributedString)->Void)?) {
        DispatchQueue.global(qos: .default).async(execute: {
            let attributedString = self.attributesTextWithHtmlString(htmlString, imageWidth)
            DispatchQueue.main.async(execute: {
                handler?(attributedString!)
            })
        })
    }
    class func attributesTextWithHtmlString(_ htmlString: String, _ width: CGFloat) -> NSAttributedString? {
        let data: Data = htmlString.data(using: .utf8)!
        let diction: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let attributedString = try? NSAttributedString(data: data, options:diction, documentAttributes: nil) else { return nil }
        let newAttributeString = NSMutableAttributedString(attributedString: attributedString)
        newAttributeString.enumerateAttribute(.paragraphStyle, in: NSRange(location: 0, length: newAttributeString.length), options: .longestEffectiveRangeNotRequired) { (value, range, stop) in
            if value is NSParagraphStyle {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 5
                paragraphStyle.paragraphSpacing = 7
                paragraphStyle.alignment = .left
//                paragraphStyle.firstLineHeadIndent = 20
                newAttributeString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
            }
        }

        let imageUrls: [String] = self.imageUrls(htmlString) ?? []
        newAttributeString.enumerateAttribute(.attachment, in: NSRange(location: 0, length: newAttributeString.length), options: .longestEffectiveRangeNotRequired, using: { (value, range, stop) in
            if value is NSTextAttachment {
                let attachment = value as! NSTextAttachment
                var imageName = URL(fileURLWithPath: URL(fileURLWithPath: attachment.fileWrapper?.preferredFilename ?? "").deletingPathExtension().path).deletingPathExtension().path
                imageName = String(imageName.suffix(imageName.count-4))
                var imgSize: CGSize = .zero
                var image: UIImage?
                for imgPath in imageUrls where imgPath.contains(imageName) {
                    imgSize = self.getImageSizeWithUrl(imgPath)
                    let data = try? Data(contentsOf: URL(string: imgPath)!)
                    image = UIImage(data: data!, scale: 0.8)
                }
                attachment.bounds = CGRect(x: 0, y: 0, width: width-5, height: width*(imgSize.height/imgSize.width))
                let newImage = image?.roundImage(size: attachment.bounds.size, cornerRadi: 10)
                attachment.image = newImage
            }
        })
        return newAttributeString
    }
    class func getImageSizeWithUrl(_ url: String?) -> CGSize {
        guard let url = url else { return .zero }
        guard let urlPath: NSURL = NSURL(string: url) else { return .zero }
        guard let source = CGImageSourceCreateWithURL(urlPath, nil) else {
            return .zero
        }
        let propertiesOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, propertiesOptions) as? [CFString: Any] else {
            return .zero
        }
        var width: Float = 0
        var height: Float = 0
        if let widthNumberRef = properties[kCGImagePropertyPixelWidth] as? CGFloat,
           let heightNumberRef = properties[kCGImagePropertyPixelHeight] as? CGFloat {
            #if __LP64__
                CFNumberGetValue(widthNumberRef as CFNumber, .float64Type, &width)
                CFNumberGetValue(heightNumberRef as CFNumber, .float64Type, &height)
            #else
                CFNumberGetValue(widthNumberRef  as CFNumber, .float32Type, &width)
                CFNumberGetValue(heightNumberRef  as CFNumber, .float32Type, &height)
            #endif
            width = Float(width)
            height = Float(height)

            let orientation = properties[kCGImagePropertyOrientation] as? UIImage.Orientation
            var temp: CGFloat = 0
            switch orientation {
            case .left, .right, .leftMirrored:
                break
            case .rightMirrored:
                temp = CGFloat(width)
                width = height
                height = Float(temp)
            default:
                break
            }
        } else {
            return .zero
        }
        return CGSize(width: Int(width), height: Int(height))
    }
    class func imageUrls(_ html: String?) -> [String]? {
        if (html?.count ?? 0) == 0 {
            return []
        }
        var array: [String] = []
        var regex: NSRegularExpression? = nil
        do {
            regex = try NSRegularExpression(pattern: "(<img\\s[\\s\\S]*?src\\s*?=\\s*?['\"](.*?)['\"][\\s\\S]*?>)+?", options: .caseInsensitive)
        } catch {
        }
        regex?.enumerateMatches(in: html ?? "", options: [], range: NSRange(location: 0, length: html?.count ?? 0), using: { result, flags, stop in
            var url: String? = nil
            if let range = result?.range(at: 2) {
                url = (html as NSString?)?.substring(with: range)
            }
            array.append(url ?? "")
        })
        return array
    }
    class func hexStringFromColor(color: UIColor) -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb = Int(r * 255.0) << 16 | Int(g * 255.0) << 8 | Int(b * 255.0) << 0
        return String(format: "#%06d", rgb)
    }
}
