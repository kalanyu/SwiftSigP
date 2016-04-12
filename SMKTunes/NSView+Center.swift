//
//  NSView+Center.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 10/16/15.
//  Copyright © 2015 KoikeLab. All rights reserved.
//

import Cocoa

extension NSView {
    var center : CGPoint {
        get {
            Swift.print(self.frame, CGPoint(x: self.frame.origin.x + (self.frame.width / 2), y: self.frame.origin.y + (self.frame.height/2)))
            return CGPoint(x: self.frame.origin.x + (self.frame.width / 2), y: self.frame.origin.y + (self.frame.height/2))
        }
    }
}
