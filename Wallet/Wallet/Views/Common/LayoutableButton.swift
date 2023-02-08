//
//  LayoutableButton.swift
//  Sports
//
//  Created by 彭显鹤pengxianhe@126.com on 2017/4/18.
//  Copyright © 2017年 彭显鹤pengxianhe@126.com. All rights reserved.
//

import UIKit
/*布局可控制的UIButton,控制图片的显示位置，可通过IB 进行设置
 layoutType:
 top:图片在上
 left：图片在左
 bottom:图片在下
 right：图片在右
 */

class LayoutableButton: UIButton {
    
    enum ButtonImageLayout {
        case top
        case left
        case bottom
        case right
        
        init(string: String?) {
            guard let string = string else {
                self = .left
                return
            }
            switch string.lowercased() {
            case "top":
                self = .top
            case "left":
                self = .left
            case "bottom":
                self = .bottom
            case "right":
                self = .right
            default:
                self = .left
            }
        }
    }
    
    open var layoutType: ButtonImageLayout = .left {
        didSet {
            configureLayout()
        }
    }
    
    @IBInspectable var _layoutType: String? {
        didSet {
            layoutType = ButtonImageLayout(string: _layoutType)
        }
    }
    
    @IBInspectable var imageTitleSpace: CGFloat = 5.0 {
        didSet {
            configureLayout()
        }
    }
    
    func configureLayout() {
        let imageSize = imageView?.frame.size ?? CGSize()
        var titleLabelSize = titleLabel?.frame.size ?? CGSize()
        let text = titleLabel?.text
        let font = titleLabel?.font
        let textSize = ((titleLabel?.text ?? "") as NSString).size(withAttributes: [NSAttributedString.Key.font: titleLabel!.font])
        let frameSize = CGSize(width: textSize.width, height: textSize.height)
        if titleLabelSize.width + 0.5 < frameSize.width {
            titleLabelSize.width = frameSize.width
        }
        switch layoutType {
        case .top:
            let totalHeight = imageSize.height + titleLabelSize.height + imageTitleSpace
            self.imageEdgeInsets = UIEdgeInsets(top: -(totalHeight - imageSize.height), left: 0, bottom: 0, right: -titleLabelSize.width)
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageSize.width, bottom: -(totalHeight - titleLabelSize.height), right: 0)
        case .left:
            self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -imageTitleSpace, bottom: 0, right: 0)
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -imageTitleSpace)
        case .bottom:
            let totalHeight = imageSize.height + titleLabelSize.height + imageTitleSpace
            self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -(totalHeight - imageSize.height), right: -titleLabelSize.width)
            self.titleEdgeInsets = UIEdgeInsets(top: -(totalHeight - titleLabelSize.height), left: -imageSize.width, bottom: 0, right: 0)
        case .right:
            self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -(titleLabelSize.width * 2 + imageTitleSpace))
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(imageSize.width * 2 + imageTitleSpace), bottom: 0, right: 0)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        configureLayout()
    }

}
