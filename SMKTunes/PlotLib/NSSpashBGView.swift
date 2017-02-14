//
//  NSSpashBGView.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 10/27/15.
//  Copyright © 2015 KoikeLab. All rights reserved.
//

import Cocoa

struct SplashBGPosition {
    var TopLeft = CGPoint(x:0, y:1)
    var TopRight = CGPoint(x:1, y:1)
    var BottomLeft = CGPoint(x:0 ,y:0)
    var BottomRight = CGPoint(x:1, y:0)
}

enum SplashDirection {
    case left
    case right
}

protocol NSSPlashViewDelegate {
    func splashAnimationEnded(startedFrom from: SplashDirection)
}

class NSSpashBGView: NSView, CALayerDelegate {
    
    var delegate: NSSPlashViewDelegate?
    let splashLayer = CALayer()
    fileprivate var splashColor : NSColor = NSColor.white
    fileprivate let initialSplashSize : CGFloat = 50
    
    required override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.wantsLayer = true
        self.splashLayer.delegate = self
        self.splashLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        self.layer?.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        self.layer?.addSublayer(splashLayer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.wantsLayer = true
        self.splashLayer.delegate = self
        self.layer?.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        self.splashLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        self.layer?.addSublayer(splashLayer)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    
    func draw(_ layer: CALayer, in ctx: CGContext) {
        
        if layer === splashLayer {

            let circlePath = NSBezierPath()
            ctx.beginPath()
            circlePath.appendOval(in: CGRect(x: 0 - (initialSplashSize/2),y: 0 - (initialSplashSize/2), width: initialSplashSize, height: initialSplashSize))
            ctx.addPath(circlePath.toCGPath()!)
            ctx.closePath()
            ctx.setFillColor(splashColor.cgColor)
            ctx.fillPath()
        }
    }
    
    func initLayers() {
        self.splashLayer.bounds = self.bounds

        self.splashLayer.anchorPoint = CGPoint(x: 0, y: 0)

        self.splashLayer.contentsScale = 2
//        self.splashLayer.bounds.origin.x = self.frame.maxX
        self.splashLayer.setNeedsDisplay()
        
//        splashFill(toColor: NSColor.whiteColor())
        
    }
    
    func splashFill(toColor color: NSColor,_ splashDirection: SplashDirection) {
        splashColor = color
        splashLayer.setNeedsDisplay()
        self.splashLayer.transform = CATransform3DMakeScale(1, 1, 1)

        if splashDirection == .right {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            let translate = CATransform3DTranslate(self.splashLayer.transform, self.bounds.maxX, 0, 0)
            self.splashLayer.transform = CATransform3DRotate(translate,CGFloat(M_PI), 0, -1, 0)
            CATransaction.commit()
        }
        
//        self.layer?.addSublayer(splashLayer)

        CATransaction.begin()
        
        CATransaction.setCompletionBlock({
//            self.splashLayer.transform = CATransform3DScale(self.splashLayer.transform, round(self.bounds.size.width * 3 / self.initialSplashSize), round(self.bounds.size.width * 3 / self.initialSplashSize), 1)
            self.layer?.backgroundColor = self.splashColor.cgColor
            self.splashLayer.backgroundColor = self.splashColor.cgColor
            self.delegate?.splashAnimationEnded(startedFrom: splashDirection)
            
//            self.splashLayer.removeFromSuperlayer()
        })
        
        let animation = CABasicAnimation(keyPath: "transform")
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.toValue = NSValue(caTransform3D: CATransform3DScale(self.splashLayer.transform, round(self.bounds.size.width * 3 / initialSplashSize), round(self.bounds.size.width * 3 / initialSplashSize), 1))
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        self.splashLayer.add(animation, forKey: "transform")
        CATransaction.commit()
    }
    
    
    func layoutSublayers(of layer: CALayer) {
        splashLayer.setNeedsDisplay()
        self.layer?.setNeedsDisplay()
    }
}
