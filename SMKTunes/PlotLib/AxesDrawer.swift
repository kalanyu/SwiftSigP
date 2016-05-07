//
//  AxesDrawer.swift
//  Calculator
//
//  Created by CS193p Instructor.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import Cocoa

class AxesDrawer
{
    var maxDataRange : Int = 1
    
    //padding parameter, moves the axes further in
    var padding = CGPointZero
    
    var color = NSColor.grayColor()
    
//    var color = NSColor.redColor()
    
    
    // set this from UIView's contentScaleFactor to position axes with maximum accuracy
    var contentScaleFactor: CGFloat = 1
    
    
    //public variables for declaring drawing coordinates to data-drawers
    var pointsPerUnit = CGPointZero
    var bounds = CGRectZero
    var position = CGPointZero
    var plotFrame = CGRectZero
    var numberOfSubticks : CGFloat = 0
    var displayLabels = true
    
    var anchorPoint = CGPointZero
    
    convenience init(color: NSColor, contentScaleFactor: CGFloat) {
        self.init()
        self.color = color
        self.contentScaleFactor = contentScaleFactor
    }
    
    convenience init(color: NSColor) {
        self.init()
        self.color = color
    }
    
    convenience init(contentScaleFactor: CGFloat) {
        self.init()
        self.contentScaleFactor = contentScaleFactor
    }
    
    // this method is the heart of the AxesDrawer
    // it draws in the current graphic context's coordinate system
    // therefore origin and bounds must be in the current graphics context's coordinate system
    // pointsPerUnit is essentially the "scale" of the axes
    // e.g. if you wanted there to be 100 points along an axis between -1 and 1,
    //    you'd set pointsPerUnit to 50
    func drawAxesInRect(context: CGContext, bounds: CGRect, axeOrigin: CGPoint, xPointsToShow: CGFloat, yPointsToShow: CGFloat = 1, numberOfTicks: Int = 0, maxDataRange: Int = 1)
    {
        //DRAWING IN LAYER CANNOT BE DONE USING NSPath Stroke
//        color.set()
        self.numberOfSubticks = CGFloat(numberOfTicks)
        self.maxDataRange = max(maxDataRange, 1)

        let ppX = (bounds.width - padding.x) / (xPointsToShow + (displayLabels ? 0.5: 0))
        var ppY = (bounds.height - padding.y) / (yPointsToShow + (displayLabels ? 0.5: 0))
        
        //TODO: the inner frame of the graph
        
        
        let posX = (bounds.origin.x + padding.x)// + ((bounds.width - padding.x) * anchorPoint.x)
        let posY = (bounds.origin.y + padding.y) + ((bounds.height - padding.y) * anchorPoint.y)
        let position = CGPoint(x: posX, y: posY )

    
        //if pointsPerY is not assigned (or default)
        if yPointsToShow == 0 {
            ppY = ppX
        }
    
        self.pointsPerUnit.x = ppX
        self.pointsPerUnit.y = ppY
        self.bounds = bounds
        self.bounds = bounds
        self.position = position
    
        let path = NSBezierPath()
        CGContextBeginPath(context)
    
        path.lineWidth = 1
        
        let lineHalfWidth = path.lineWidth / 2
        

//        CGContextSetFillColorWithColor(context, NSColor(red: 0, green: 0, blue: 0, alpha: 0.9).CGColor)
        CGContextSetFillColorWithColor(context, NSColor(red: 1, green: 1, blue: 1, alpha: 0.95).CGColor)

        CGContextFillRect(context, CGRect(x: bounds.minX + padding.x, y: bounds.minY + padding.y, width:  bounds.width, height: bounds.height))
        
        //draw x-axis
        path.moveToPoint(CGPoint(x: bounds.minX + padding.x, y: align(position.y + lineHalfWidth)))
        path.lineToPoint(CGPoint(x: bounds.maxX, y: align(position.y + lineHalfWidth)))
        
        //draw y-axis
        path.moveToPoint(CGPoint(x: align(position.x + lineHalfWidth), y: align(bounds.minY + padding.y) ))
        path.lineToPoint(CGPoint(x: align(position.x + lineHalfWidth), y: bounds.maxY))
        
        //closing the borders on all four sides (incase where the origin is not (0,0)
        path.moveToPoint(CGPoint(x: bounds.minX + padding.x, y: bounds.minY + padding.y + lineHalfWidth))
        path.lineToPoint(CGPoint(x: bounds.minX + padding.x, y: bounds.maxY - lineHalfWidth))

        
        path.moveToPoint(CGPoint(x: bounds.minX + padding.x, y: bounds.maxY - lineHalfWidth))
        path.lineToPoint(CGPoint(x: bounds.maxX, y: bounds.maxY - lineHalfWidth))
        
        path.moveToPoint(CGPoint(x: bounds.maxX - lineHalfWidth, y: bounds.maxY - lineHalfWidth))
        path.lineToPoint(CGPoint(x: bounds.maxX - lineHalfWidth, y: bounds.minY + padding.y))
        
        path.moveToPoint(CGPoint(x: bounds.minX + padding.x, y: bounds.minY + padding.y + lineHalfWidth))
        path.lineToPoint(CGPoint(x: bounds.maxX, y: bounds.minY + padding.y + lineHalfWidth))
        
        CGContextAddPath(context, path.toCGPath())
        CGContextSetStrokeColorWithColor(context, NSColor.grayColor().CGColor)
        CGContextSetLineWidth(context, 1)
        CGContextStrokePath(context)
        path.removeAllPoints()
        
        //for now, disabling this decreases 30% of CPU usage
        CGContextBeginPath(context)
    
        for gridSpacing in align(bounds.minX + padding.x).stride(to: bounds.maxX, by: align(ppX)) {
            path.moveToPoint(CGPoint(x: align(gridSpacing), y: align(bounds.minY + padding.y)))
            path.lineToPoint(CGPoint(x: align(gridSpacing), y: bounds.maxY))
        }
        
        for gridSpacing in align(posY).stride(to: bounds.maxY, by: align(ppY) / numberOfSubticks) {
            path.moveToPoint(CGPoint(x: bounds.minX + padding.x, y: align(gridSpacing)))
            path.lineToPoint(CGPoint(x: bounds.maxX, y: align(gridSpacing)))
        }
        

        for gridSpacing in align(posY).stride(to: bounds.minY, by: align(ppY)) {
            path.moveToPoint(CGPoint(x: bounds.minX + padding.x, y: align(gridSpacing)))
            path.lineToPoint(CGPoint(x: bounds.maxX, y: align(gridSpacing)))
        }
    
        CGContextAddPath(context, path.toCGPath())
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        CGContextSetLineWidth(context, 0.25)
        CGContextStrokePath(context)
        
    }



    
    // we want the axes and hashmarks to be exactly on pixel boundaries so they look sharp
    // setting contentScaleFactor properly will enable us to put things on the closest pixel boundary
    // if contentScaleFactor is left to its default (1), then things will be on the nearest "point" boundary instead
    // the lines will still be sharp in that case, but might be a pixel (or more theoretically) off of where they should be
    
    private func alignedPoint(x x: CGFloat, y: CGFloat, insideBounds: CGRect? = nil) -> CGPoint?
    {
        let point = CGPoint(x: align(x), y: align(y))
        if let permissibleBounds = insideBounds {
            if (!CGRectContainsPoint(permissibleBounds, point)) {
                return nil
            }
        }
        return point
    }
    
    private func align(coordinate: CGFloat) -> CGFloat {
        return round(coordinate * contentScaleFactor) / contentScaleFactor
    }
}

extension CGRect
{
    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x-size.width/2, y: center.y-size.height/2, width: size.width, height: size.height)
    }
}
