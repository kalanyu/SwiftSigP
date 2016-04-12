//
//  RoundProgressView.swift
//  SMKTunes
//
//  Created by Kalanyu Zintus-art on 11/1/15.
//  Copyright © 2015 KoikeLab. All rights reserved.
//

import Cocoa

protocol RoundProgressProtocol {
    func roundProgressClicked(sender: NSView)
}

@IBDesignable class RoundProgressView: NSView {
    private let innerRing = CAShapeLayer()
    private let outerRing = CAShapeLayer()

    private let lineWidth : CGFloat = 10
    private let titleLabel = NSTextLabel()
    
    var roundDelegate : RoundProgressProtocol?
    
    var title : String {
        get {
            return titleLabel.stringValue
        }
        set {
            titleLabel.stringValue = newValue
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.wantsLayer = true
        self.layer?.addSublayer(innerRing)
        self.layer?.addSublayer(outerRing)
        
        innerRing.shouldRasterize = true
        innerRing.rasterizationScale = 2
        innerRing.strokeColor = NSColor(red: 255/255.0, green: 133/255.0, blue: 156/255.0, alpha: 1).CGColor
        innerRing.fillColor = NSColor.clearColor().CGColor
        innerRing.lineWidth = lineWidth
        innerRing.lineCap = kCALineCapRound
        innerRing.lineDashPattern = nil
        innerRing.lineDashPhase = 0.0
        //testLayer.strokeEnd = 0
        
        
        outerRing.shouldRasterize = true
        outerRing.rasterizationScale = 2
        outerRing.strokeColor = NSColor.whiteColor().CGColor
        outerRing.fillColor = NSColor.clearColor().CGColor
        outerRing.lineWidth = lineWidth
        outerRing.lineCap = kCALineCapRound
        outerRing.lineDashPattern = nil
        outerRing.lineDashPhase = 0.0

        titleLabel.textColor = NSColor.whiteColor()
        self.addSubview(titleLabel)
        
        self.titleLabel.font = NSFont.boldSystemFontOfSize(20)
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        var countFieldConstraint = NSLayoutConstraint(item: self.titleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        self.addConstraint(countFieldConstraint)
        countFieldConstraint = NSLayoutConstraint(item: self.titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        self.addConstraint(countFieldConstraint)
        
        titleLabel.stringValue = "Title"
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        
        //CGPathMoveToPoint(path, nil, 0, 0)
        //CGPathAddArc(path, nil, 0, 0, 300, 0, CGFloat(M_PI), false)
        let path = CGPathCreateMutable()
        Swift.print(self.bounds.width)
        var circleSize : CGFloat = min(self.bounds.width/2, self.bounds.height/2)
        let margin = lineWidth + 10
        CGPathAddArc(path, nil, self.bounds.midX, self.bounds.midY, circleSize - margin, CGFloat(-M_PI/2), CGFloat(19 * M_PI / 12.6), true)
        //CGPathAddArc(path, nil, 100, 100, 100, 0, (360 * CGFloat(M_PI))/180, true);
        
        circleSize = min(self.bounds.width, self.bounds.height) - margin
        
        let path2 = CGPathCreateMutable()
        CGPathAddEllipseInRect(path2, nil, CGRect(x: self.bounds.midX - (circleSize/2), y: self.bounds.midY - (circleSize/2), width: circleSize, height: circleSize))
        
        outerRing.path = path2
        innerRing.path = path
        innerRing.strokeEnd = 0
        // Drawing code here.
    }
    
    override func layout() {
        super.layout()
        titleLabel.font = NSFont.boldSystemFontOfSize(resizeFontWithString(titleLabel.stringValue))
        titleLabel.sizeToFit()
        titleLabel.frame.origin = CGPoint(x: self.bounds.midX - titleLabel.bounds.width/2, y: self.bounds.midY - titleLabel.bounds.height/2)
    }
    
    func loadProgressForSeconds(seconds: Double) {
        CATransaction.begin()
        
        let animate = CABasicAnimation(keyPath: "strokeEnd")
        animate.toValue = 1
        animate.duration = seconds
        animate.repeatCount = 1
        animate.fillMode = kCAFillModeForwards
        animate.removedOnCompletion = false

        innerRing.addAnimation(animate, forKey: "strokeEnd")
        CATransaction.commit()
    }

    private func resizeFontWithString(title: String) -> CGFloat {
        //        defer {
        //            Swift.print(textSize, self.bounds, displaySize)
        //        }
        
        let smallestSize : CGFloat = 10
        let largestSize : CGFloat = 40
        var textSize = CGSizeZero
        var displaySize = smallestSize
        
        while displaySize < largestSize {
            let nsTitle = NSString(string: title)
            let attributes = [NSFontAttributeName: NSFont.boldSystemFontOfSize(displaySize)]
            textSize = nsTitle.sizeWithAttributes(attributes)
            if textSize.width < self.bounds.width - (lineWidth * 2) * 4 {
                //                Swift.print(displaySize, "increasing")
                displaySize += 1
            } else {
                Swift.print(displaySize)
                return displaySize
            }
        }
        return largestSize
    }
    
    override func mouseDown(theEvent: NSEvent) {
        if let delegate = roundDelegate {
            delegate.roundProgressClicked(self)
        }
    }
}
