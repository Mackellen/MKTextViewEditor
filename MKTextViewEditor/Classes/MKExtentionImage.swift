//
//  MKExtentionImage.swift
//  MKTextViewEditor
//
//  Created by Mackellen on 2021/2/25.
//

import UIKit

extension UIImage {
    
    public func roundImage(size: CGSize, cornerRadi: CGFloat) -> UIImage? {
        return roundImage(size: size, cornerRadii: CGSize(width: cornerRadi, height: cornerRadi))
    }
    
    public func roundImage(size: CGSize, cornerRadii: CGSize) -> UIImage? {
        let imageRect = CGRect(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        let context = UIGraphicsGetCurrentContext()
        guard context != nil else {
            return nil
        }
        context?.setShouldAntialias(true)
        let bezierPath = UIBezierPath(roundedRect: imageRect,
                                      byRoundingCorners: UIRectCorner.allCorners,
                                      cornerRadii: cornerRadii)
        bezierPath.close()
        bezierPath.addClip()
        self.draw(in: imageRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
}
