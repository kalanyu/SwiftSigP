//
//  SRPlotAxe.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 10/15/15.
//  Copyright © 2015 KoikeLab. All rights reserved.
//

import Cocoa
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class SRPlotAxe: NSObject, NSWindowDelegate, CALayerDelegate {
    //TODO: Separate axis layer and hashmarks drawer for less redraws and improved performance
    //TODO: Support axe origin shift
    enum SRPlotSignalType {
        case split
        case merge
    }
    //1. where the moving hash marks will be drawn
    let hashLayer = CALayer()
    //2. where the axis will be drawn
    let layer = CALayer()
    //3. axis layer, where the actual data will be plot
    let dataLayer = CALayer()
    
    var numberOfSubticks : Int = 0
    var maxDataRange : Int = 1 {
        didSet {
            self.hashLayer.setNeedsDisplay()
        }
    }
    
    var graph = AxesDrawer()
    var hashSystem = HashDrawer()
    
    var signalType = SRPlotSignalType.split
    
    //axis origin that causes the axe to move
    var origin : CGPoint?
    
    var xPointsToShow : CGFloat? {
        didSet {
            layer.setNeedsDisplay()
        }
    }
    var yPointsToShow: CGFloat? {
        didSet {
            layer.setNeedsDisplay()
        }
    }
    
    var samplingRate : Double = 60
    
    var padding = CGPoint.zero {
        didSet {
            graph.padding = padding
            hashSystem.padding = padding
        }
    }
    
    var contentsScale : CGFloat {
        get {
            return layer.contentsScale
        }
        
        set {
            layer.contentsScale = newValue
            hashLayer.contentsScale = newValue
            manageDataSublayers()
        }
    }
    
    var innerTopRightPadding : CGFloat = 10
    
    convenience init(frame frameRect: CGRect) {
        self.init()
        
        hashLayer.delegate = self
        hashLayer.anchorPoint = CGPoint.zero
        hashLayer.needsDisplayOnBoundsChange = true
        hashLayer.bounds = CGRect(x: 0, y: 0, width: frameRect.width, height: frameRect.height)
        hashLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
//        self.hashLayer.addSublayer(self.layer)
        
        layer.delegate = self
        layer.anchorPoint = CGPoint.zero
        //MUST: set anchorpoint first or else set frame will shift it else where due to the coordinate system
        layer.needsDisplayOnBoundsChange = true
//        Swift.print(layer.bounds)
        layer.bounds = CGRect(x: 0, y: 0, width: hashLayer.bounds.width - innerTopRightPadding, height: hashLayer.bounds.height - innerTopRightPadding)
        //SWIFT 2.0 Syntax : Option Settypes
        layer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        
        self.dataLayer.anchorPoint = CGPoint.zero
        self.dataLayer.bounds = CGRect(x: 0, y: 0, width: layer.bounds.width, height: layer.bounds.height )
        //if parent layer has implicit and children don't have it, ghosting occurs!
        //fix: disable animation makes ghosting disappear !!!!
        self.dataLayer.delegate = self

        let masking = CALayer()
//        masking.anchorPoint = CGPoin
        masking.backgroundColor = NSColor.black.cgColor
        self.dataLayer.mask = masking
        
        self.layer.insertSublayer(self.dataLayer, below: self.layer)
        self.layer.insertSublayer(self.hashLayer, at: 0)

        

    }
    
    convenience init(frame: CGRect, axeOrigin: CGPoint, xPointsToShow: CGFloat, yPointsToShow: CGFloat, numberOfSubticks: Int = 0) {
        self.init(frame: frame)
        
        self.origin = axeOrigin
        self.xPointsToShow = xPointsToShow
        self.yPointsToShow = yPointsToShow
        self.numberOfSubticks = numberOfSubticks
        
    }
    
    convenience init(frame: CGRect, axeOrigin: CGPoint, xPointsToShow: CGFloat, numberOfSubticks: Int = 0, maxDataRange: Int = 1) {
        self.init(frame: frame, axeOrigin: axeOrigin, xPointsToShow: xPointsToShow, yPointsToShow: 1, numberOfSubticks: numberOfSubticks)
        self.maxDataRange = maxDataRange
    }
    
    func draw(_ layer: CALayer, in ctx: CGContext) {
        guard layer === self.layer || layer === self.hashLayer else {
            return
        }
        
        if (layer === self.layer) {
            graph.drawAxesInRect(ctx, bounds: self.layer.bounds, axeOrigin: origin!, xPointsToShow: xPointsToShow!, yPointsToShow: yPointsToShow!, numberOfTicks: numberOfSubticks, maxDataRange: self.maxDataRange)
        } else if (layer === self.hashLayer) {
            hashSystem.drawHashInRect(ctx, bounds: self.layer.bounds, axeOrigin: origin!, xPointsToShow: xPointsToShow!, yPointsToShow: yPointsToShow!, numberOfTicks: numberOfSubticks, maxDataRange: self.maxDataRange)
        }
        
    }
    
    func layoutSublayers(of layer: CALayer) {
        //=== identical to : refers to the same memory
        //== equal in value
        guard layer === self.dataLayer && self.dataLayer.sublayers?.count > 0 else {
            return
        }
        //resize clipping mask
        if layer.mask != nil {
            layer.mask!.bounds = self.layer.bounds
            layer.mask!.bounds.size.height = self.layer.bounds.height * 2
            layer.mask!.bounds.size.width = self.layer.bounds.width - self.padding.x
        }
        var translation = CATransform3DMakeTranslation(self.layer.bounds.width / 2 + self.graph.position.x, self.layer.bounds.height / 2, 0)
        
        //        FIXME: set this up in initializer somewhere
        //        left to right mode
        if layer.mask != nil {
            layer.mask!.position.x = self.graph.position.x + (self.layer.bounds.width / 2)
            layer.mask!.position.y = self.graph.position.y
        }
        // right to left mode
        translation = CATransform3DMakeTranslation(self.graph.bounds.width + self.graph.position.x, 0, 0)
        layer.mask!.position.x =  (self.layer.bounds.width / 2) + self.padding.x/2
        layer.transform = CATransform3DRotate(translation, CGFloat(M_PI), 0, 1, 0)
    }
    
    func action(for layer: CALayer, forKey event: String) -> CAAction? {
        //disable implicit animation of any kind
        return NSNull()
    }
    
    //MARK: NSWindowDelegate

    func rescaleSublayers() {
        //set layer's contentScale for crisp display
        guard let sublayers = self.dataLayer.sublayers, self.dataLayer.sublayers?.count > 0 else {
            return
        }
        for sublayer in sublayers {
            sublayer.contentsScale = NSApplication.shared().windows[0].backingScaleFactor
        }
        self.layer.contentsScale = NSApplication.shared().windows[0].backingScaleFactor
        self.hashLayer.contentsScale = NSApplication.shared().windows[0].backingScaleFactor
    }
    
    //MARK: Utilities
    func manageDataSublayers() {
        guard let sublayers = self.dataLayer.sublayers, self.dataLayer.sublayers?.count > 0 else {
            return
        }
        
        
        for sublayer in sublayers {
            sublayer.frame.size.width = 0
            sublayer.frame.size.height = 0
        }
        
    }
    
    fileprivate func align(_ coordinate: CGFloat) -> CGFloat {
        return round(coordinate * layer.contentsScale) / layer.contentsScale
    }
    
}
