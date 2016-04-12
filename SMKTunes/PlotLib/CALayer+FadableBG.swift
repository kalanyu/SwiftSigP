//
//  CALayer+FadableBG.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 10/27/15.
//  Copyright © 2015 KoikeLab. All rights reserved.
//

import Cocoa

extension CALayer {
    
    func fadeBackground(toColor color: NSColor, duration: Double, timing: String = kCAMediaTimingFunctionEaseOut) {
        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "backgroundColor")
        CATransaction.setCompletionBlock({
            self.backgroundColor = NSColor.blueColor().CGColor
        })
        animation.duration = 2.0
        animation.timingFunction = CAMediaTimingFunction(name: timing)
        animation.toValue = NSColor.blueColor().CGColor
        self.addAnimation(animation, forKey: "backgroundColor")
        
        CATransaction.commit()
    }
}
