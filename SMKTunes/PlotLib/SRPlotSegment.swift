//
//  SRPlotSegment.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 10/14/15.
//  Copyright © 2015 KoikeLab. All rights reserved.
//

import Cocoa

class SRPlotSegment : NSObject {

    let layer = CALayer()
    
    private var axeSystem : SRPlotAxe?
    private var index: Int = 0;
    private var dataStorage = [[Double]]()

    
    required override init() {
        super.init()
        layer.delegate = self
        layer.opaque = false
        layer.anchorPoint = CGPoint(x: 0, y: 0.5)
    }
    
    convenience init(axesSystem axe: SRPlotAxe, channels: Int) {
        self.init()
        self.axeSystem = axe
        self.index = 60
        dataStorage = [[Double]](count: channels, repeatedValue: [Double](count: self.index, repeatedValue: 0))
        self.layer.bounds = CGRectMake(0, 0, axeSystem!.graph.pointsPerUnit.x, axeSystem!.graph.bounds.height)
    }

    
    override func drawLayer(layer: CALayer, inContext ctx: CGContext) {
        //skip drawing if graph layer does not exist
        if self.axeSystem == nil {
            return
        }
        
        // Draw the graph
        var lines = [CGPoint](count: 120, repeatedValue: CGPointZero)
        
        
        //Create Lines
        //FIXME: Will Bezier path gives smoother lines?
        for var c = 0; c < dataStorage.count; ++c
        {
            for var i = 0 ; i < 59 ; ++i {
                let data = minMaxNormalization(dataStorage[c][i], min: -axeSystem!.graph.maxDataRange, max: axeSystem!.graph.maxDataRange)
                let nextData = minMaxNormalization(dataStorage[c][i+1], min: -axeSystem!.graph.maxDataRange, max: axeSystem!.graph.maxDataRange)
                //merge axis and  min max normalization using its range
                let apy = axeSystem!.graph.anchorPoint.y
                let ppx = axeSystem!.graph.pointsPerUnit.x
                let ppy = axeSystem!.graph.pointsPerUnit.y
                let channelPos = (axeSystem!.signalType == .Split) ? CGFloat(c) * ppy : 0
                
                lines[i*2].x = align(CGFloat(i) * (ppx / 60))
                lines[i*2].y = (channelPos + (self.layer.bounds.height * apy)) + (CGFloat(data) * ppy)
                lines[i*2+1].x = align(CGFloat(i+1) * (ppx / 60))
                lines[i*2+1].y =  (channelPos + (self.layer.bounds.height * apy)) + (CGFloat(nextData) * ppy)
            }
            //get prism color for each specific channel
            CGContextSetLineWidth(ctx, 1.5);
            CGContextSetStrokeColorWithColor(ctx, NSColor.prismColor[c].CGColor);
            CGContextStrokeLineSegments(ctx, lines, 120);
        }
        
    }
    
    func reset()
    {
        // Clear out our components and reset the index to 60 to start filling values again...
        for var i = 0; i < dataStorage.count; ++i {
            dataStorage[i] = [Double](count:60, repeatedValue: 0)
        }
        
        index = 60;
        // Inform Core Animation that we need to redraw this layer.
        layer.setNeedsDisplay()
    }
    
    func isFull() -> Bool {
        // Simple, this segment is full if there are no more space in the history.
        return index == 0;
    }
    
    func isVisibleInRect(r: CGRect)-> Bool {
        // Just check if there is an intersection between the layer's frame and the given rect.
        // but return to when the graph is coming from left-off-screen (still invisible)
        
        if layer.frame.origin.x < r.origin.x {
            return true
        }
        
        return CGRectIntersectsRect(r, (layer.frame));
    }
    
    func add(data: [Double]) -> Bool {
        
        // If this segment is not full, then we add data value to the history.
        if index > 0
        {
            // First decrement, both to get to a zero-based index and to flag one fewer position left
            --index;
            
            // prevent index out of bounds issue
            let lastAvailableChannel = min(data.count, dataStorage.count)
            for var i = 0 ; i < lastAvailableChannel ; ++i {
                dataStorage[i][index] = data[i]
            }
            // And inform Core Animation to redraw the layer.
            layer.setNeedsDisplay();
        }
        // And return if we are now full or not (really just avoids needing to call isFull after adding a value).
        return index == 0;
    }
    
    override func actionForLayer(layer: CALayer, forKey event: String) -> CAAction? {
        //nil, null, Nil, NSNull, [NSNull null]? Dang it
        return NSNull()
    }
    
    private func align(coordinate: CGFloat) -> CGFloat {
        //align points
        return round(coordinate * layer.contentsScale) / layer.contentsScale
    }
    
    private func minMaxNormalization(input: Double, min: Int, max: Int) -> Double {
        let minRange : Double = (axeSystem!.signalType == .Split) ? 0 : -1
        return ((input - Double(min))/(Double(max) - Double(min))) * (1 - minRange) + minRange

    }
    
    override func layer(layer: CALayer, shouldInheritContentsScale newScale: CGFloat, fromWindow window: NSWindow) -> Bool {
        return true
    }

    
}

