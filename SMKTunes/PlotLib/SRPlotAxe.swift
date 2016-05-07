//
//  SRPlotAxe.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 10/15/15.
//  Copyright © 2015 KoikeLab. All rights reserved.
//

import Cocoa

class SRPlotAxe: NSObject, NSWindowDelegate {
    //TODO: Separate axis layer and hashmarks drawer for less redraws and improved performance
    //TODO: Support axe origin shift
    enum SRPlotSignalType {
        case Split
        case Merge
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
    
    var signalType = SRPlotSignalType.Split
    
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
    
    var padding = CGPointZero {
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
        hashLayer.anchorPoint = CGPointZero
        hashLayer.needsDisplayOnBoundsChange = true
        hashLayer.bounds = CGRectMake(0, 0, frameRect.width, frameRect.height)
        hashLayer.autoresizingMask = [.LayerWidthSizable, .LayerHeightSizable]
//        self.hashLayer.addSublayer(self.layer)
        
        layer.delegate = self
        layer.anchorPoint = CGPointZero
        //MUST: set anchorpoint first or else set frame will shift it else where due to the coordinate system
        layer.needsDisplayOnBoundsChange = true
//        Swift.print(layer.bounds)
        layer.bounds = CGRectMake(0, 0, hashLayer.bounds.width - innerTopRightPadding, hashLayer.bounds.height - innerTopRightPadding)
        //SWIFT 2.0 Syntax : Option Settypes
        layer.autoresizingMask = [.LayerWidthSizable, .LayerHeightSizable]
        
        self.dataLayer.anchorPoint = CGPointZero
        self.dataLayer.bounds = CGRect(x: 0, y: 0, width: layer.bounds.width, height: layer.bounds.height )
        //if parent layer has implicit and children don't have it, ghosting occurs!
        //fix: disable animation makes ghosting disappear !!!!
        self.dataLayer.delegate = self

        let masking = CALayer()
//        masking.anchorPoint = CGPoin
        masking.backgroundColor = NSColor.blackColor().CGColor
        self.dataLayer.mask = masking
        
        self.layer.insertSublayer(self.dataLayer, below: self.layer)
        self.layer.insertSublayer(self.hashLayer, atIndex: 0)

        

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
    
    override func drawLayer(layer: CALayer, inContext ctx: CGContext) {
        guard layer === self.layer || layer === self.hashLayer else {
            return
        }
        
        if (layer === self.layer) {
            graph.drawAxesInRect(ctx, bounds: self.layer.bounds, axeOrigin: origin!, xPointsToShow: xPointsToShow!, yPointsToShow: yPointsToShow!, numberOfTicks: numberOfSubticks, maxDataRange: self.maxDataRange)
        } else if (layer === self.hashLayer) {
            hashSystem.drawHashInRect(ctx, bounds: self.layer.bounds, axeOrigin: origin!, xPointsToShow: xPointsToShow!, yPointsToShow: yPointsToShow!, numberOfTicks: numberOfSubticks, maxDataRange: self.maxDataRange)
        }
        
    }
    
    override func layoutSublayersOfLayer(layer: CALayer) {
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
    
    override func actionForLayer(layer: CALayer, forKey event: String) -> CAAction? {
        //disable implicit animation of any kind
        return NSNull()
    }
    
    //MARK: NSWindowDelegate

    func rescaleSublayers() {
        //set layer's contentScale for crisp display
        guard let sublayers = self.dataLayer.sublayers where self.dataLayer.sublayers?.count > 0 else {
            return
        }
        for sublayer in sublayers {
            sublayer.contentsScale = NSApplication.sharedApplication().windows[0].backingScaleFactor
        }
        self.layer.contentsScale = NSApplication.sharedApplication().windows[0].backingScaleFactor
        self.hashLayer.contentsScale = NSApplication.sharedApplication().windows[0].backingScaleFactor
    }
    
    //MARK: Utilities
    func manageDataSublayers() {
        guard let sublayers = self.dataLayer.sublayers where self.dataLayer.sublayers?.count > 0 else {
            return
        }
        
        
        for sublayer in sublayers {
            sublayer.frame.size.width = 0
            sublayer.frame.size.height = 0
        }
        
    }
    
    private func align(coordinate: CGFloat) -> CGFloat {
        return round(coordinate * layer.contentsScale) / layer.contentsScale
    }
    
}
