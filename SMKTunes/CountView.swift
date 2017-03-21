//
//  HalfCircleMeterView.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 10/5/15.
//  Copyright © 2015 KoikeLab. All rights reserved.
//

import Cocoa
import SwiftR

@IBDesignable class CountView: NSView {
    
    private var titleField : SRLabel?
    private var countField : SRLabel?

    var title : String = "" {
        didSet {
            self.titleField?.stringValue = self.title
        }
    }
    
    var directionValue : Int {
        get {
			return NumberFormatter().number(from: self.countText)!.intValue
        }
        set {
			if let countNumber = NumberFormatter().string(from: NSNumber(value: newValue)) {
                if newValue > 0 {
                    self.countText = "+\(countNumber)"
                } else if newValue <= 0 {
                    self.countText = countNumber
                }
            } else {
                self.countText = "0"
            }
        }
    }
    
    var countText : String = "0" {
        didSet {
            //already has layout constraints, no need for frame adjustment
            //TODO:size adjustments for readability
            countField?.stringValue = self.countText
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        titleField = SRLabel(frame: CGRect.zero)
        countField = SRLabel(frame: CGRect.zero)
        
        titleField?.textColor = NSColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1)
        countField?.textColor = NSColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1)

        self.addSubview(titleField!)
        self.addSubview(countField!)
        
		self.titleField?.font = NSFont.boldSystemFont(ofSize: 20)
		self.countField?.font = NSFont.systemFont(ofSize: 100)
        self.countField?.translatesAutoresizingMaskIntoConstraints = false
        var countFieldConstraint = NSLayoutConstraint(item: self.countField!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(countFieldConstraint)
        countFieldConstraint = NSLayoutConstraint(item: self.countField!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraint(countFieldConstraint)
        
        self.titleField?.translatesAutoresizingMaskIntoConstraints = false
        let titleFieldConstraint = NSLayoutConstraint(item: self.titleField!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(titleFieldConstraint)

        countField?.stringValue = "0"
        titleField?.stringValue = "Title"
        
        self.wantsLayer = true
//        self.layer?.backgroundColor = CGColorCreateGenericRGB(0, 0 , 0, 0.05)
//        self.layer?.borderColor = NSColor.darkGrayColor().CGColor
//        self.layer?.borderWidth = 1

    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)


        // Drawing code here.
    }
    
    override func layout() {
        super.layout()
		countField?.font = NSFont.boldSystemFont(ofSize: resizeFontWithString(title: countField!.stringValue))
    }
    
    private func resizeFontWithString(title: String) -> CGFloat {
//        defer {
//            Swift.print(textSize, self.bounds, displaySize)
//        }
        
        let smallestSize : CGFloat = 100
        let largestSize : CGFloat = 200
        var textSize = CGSize.zero
        var displaySize = smallestSize
        
        while displaySize < largestSize {
            let nsTitle = NSString(string: title)
			let attributes = [NSFontAttributeName: NSFont.boldSystemFont(ofSize: displaySize)]
			textSize = nsTitle.size(withAttributes: attributes)
            if textSize.width < self.bounds.width * 0.8 {
//                Swift.print(displaySize, "increasing")
                displaySize += 1
            } else {
                Swift.print(displaySize)
                return displaySize
            }
        }
        return largestSize
    }
}
