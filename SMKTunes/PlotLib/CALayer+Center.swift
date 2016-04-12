//
//  CALayer+Center.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 10/16/15.
//  Copyright © 2015 KoikeLab. All rights reserved.
//

import Cocoa

extension CALayer {
    
    /**
    Just testing documentation using Markdown
    - returns: Bool
    - parameter param1:String
    - parameter param2:String
    - Throws: error lists
    */
    func centerInSuperlayer() -> Bool {
        if self.superlayer == nil {
            return false
        }
        
        return centerInLayer(self.superlayer!)
    }

    func centerInLayer(layer: CALayer) -> Bool {
        self.position = CGPointMake(layer.bounds.width/2, layer.bounds.height/2)
        //success
        return true
    }
    
    
}
