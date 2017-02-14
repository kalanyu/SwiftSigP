//
//  NSBezierPath+CGPath.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 10/16/15.
//  Copyright © 2015 KoikeLab. All rights reserved.
// Credit : icodeforlove
// URL : https://gist.github.com/jorgenisaksson/76a8dae54fd3dc4e31c2

import Cocoa

extension NSBezierPath {
    func toCGPath () -> CGPath? {
        if self.elementCount == 0 {
            return nil
        }
        
        let path = CGMutablePath()
        var didClosePath = false
        
        for i in 0...self.elementCount-1 {
            var points = [NSPoint](repeating: NSZeroPoint, count: 3)
            
            switch self.element(at: i, associatedPoints: &points) {
//							case .moveToBezierPathElement:CGPathMoveToPoint(path, nil, points[0].x, points[0].y)
//							case .lineToBezierPathElement:CGPathAddLineToPoint(path, nil, points[0].x, points[0].y)
//							case .curveToBezierPathElement:CGPathAddCurveToPoint(path, nil, points[0].x, points[0].y, points[1].x, points[1].y, points[2].x, points[2].y)
							case .moveToBezierPathElement:path.move(to: points[0])
							case .lineToBezierPathElement:path.addLine(to: points[0])
							case .curveToBezierPathElement:path.addCurve(to: points[0], control1: points[1], control2: points[2])
							case .closePathBezierPathElement:path.closeSubpath()
							didClosePath = true;
            }
        }
        
        if !didClosePath {
            path.closeSubpath()
        }
        
        return path.copy()
    }
}
