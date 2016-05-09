//
//  HalfCircleMeterView.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 10/5/15.
//  Copyright © 2015 KoikeLab. All rights reserved.
//

import Cocoa

@IBDesignable class CountView: NSView {
    
    private var titleField : NSTextLabel?
    private var countField : NSTextLabel?

    var title : String = "" {
        didSet {
            self.titleField?.stringValue = self.title
        }
    }
    
    var directionValue : Int? {
        get {
            return NSNumberFormatter().numberFromString(self.countText)?.integerValue
        }
        set {
            if let countNumber = NSNumberFormatter().stringFromNumber(NSNumber(integer: newValue!)) {
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
        titleField = NSTextLabel(frame: CGRectZero)
        countField = NSTextLabel(frame: CGRectZero)
        
        titleField?.textColor = NSColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1)
        countField?.textColor = NSColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1)

        self.addSubview(titleField!)
        self.addSubview(countField!)
        
        self.titleField?.font = NSFont.boldSystemFontOfSize(20)
        self.countField?.font = NSFont.systemFontOfSize(100)
        self.countField?.translatesAutoresizingMaskIntoConstraints = false
        var countFieldConstraint = NSLayoutConstraint(item: self.countField!, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        self.addConstraint(countFieldConstraint)
        countFieldConstraint = NSLayoutConstraint(item: self.countField!, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        self.addConstraint(countFieldConstraint)
        
        self.titleField?.translatesAutoresizingMaskIntoConstraints = false
        let titleFieldConstraint = NSLayoutConstraint(item: self.titleField!, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        self.addConstraint(titleFieldConstraint)

        countField?.stringValue = "0"
        titleField?.stringValue = "Title"
        
        self.wantsLayer = true
//        self.layer?.backgroundColor = CGColorCreateGenericRGB(0, 0 , 0, 0.05)
//        self.layer?.borderColor = NSColor.darkGrayColor().CGColor
//        self.layer?.borderWidth = 1

    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)


        // Drawing code here.
    }
    
    override func layout() {
        super.layout()
        countField?.font = NSFont.boldSystemFontOfSize(resizeFontWithString(countField!.stringValue))
    }
    
    private func resizeFontWithString(title: String) -> CGFloat {
//        defer {
//            Swift.print(textSize, self.bounds, displaySize)
//        }
        
        let smallestSize : CGFloat = 100
        let largestSize : CGFloat = 200
        var textSize = CGSizeZero
        var displaySize = smallestSize
        
        while displaySize < largestSize {
            let nsTitle = NSString(string: title)
            let attributes = [NSFontAttributeName: NSFont.boldSystemFontOfSize(displaySize)]
            textSize = nsTitle.sizeWithAttributes(attributes)
            if textSize.width < self.bounds.width * 0.8 {
//                Swift.print(displaySize, "increasing")
                displaySize += 1
            } else {
//                Swift.print(displaySize)
                return displaySize
            }
        }
        return largestSize
    }
}
