//
//  YHLineChartRenderer.swift
//  ChartDemo
//
//  Created by young on 2019/1/8.
//  Copyright © 2019 young. All rights reserved.
//

import UIKit
import Charts

@objcMembers public class HierarchyColor: NSObject {
    let y: Double
    let color: UIColor
    
    init(y: Double, color: UIColor)
    {
        self.y = y
        self.color = color
        super.init()
    }
}

class YHLineChartRenderer: LineChartRenderer {
    @objc open var hierarchyColors: [HierarchyColor]? = []
    
    override open func drawLinear(context: CGContext, dataSet: ILineChartDataSet)
    {
        guard let dataProvider = dataProvider else { return }
        let xBounds = XBounds()
        var _lineSegments : [CGPoint] = []

        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        let entryCount = dataSet.entryCount
        let isDrawSteppedEnabled = dataSet.mode == .stepped
        let pointsPerEntryPair = isDrawSteppedEnabled ? 4 : 2
        
        let phaseY = animator.phaseY
        
        xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        // if drawing filled is enabled
        if dataSet.isDrawFilledEnabled && entryCount > 0
        {
            drawLinearFill(context: context, dataSet: dataSet, trans: trans, bounds: xBounds)
        }
        
        context.saveGState()
        
        context.setLineCap(dataSet.lineCapType)
        
        // more than 1 color
        let limitYCount = self.hierarchyColors?.count ?? 0
        if limitYCount > 0
        {
            var colorIndex = 0
            for j in stride(from: xBounds.min, through: xBounds.range + xBounds.min, by: 1)
            {
                let e: ChartDataEntry! = dataSet.entryForIndex(j)
                if e == nil { continue }
                let p = CGPoint(x:e.x,y:e.y * phaseY)
                var index = 0
                for i in 0...(limitYCount - 1) {
                    if e.y <= self.hierarchyColors![i].y || i == limitYCount - 1 {
                        index = i
                        break;
                    } else {
                        continue
                    }
                }
                if index == colorIndex || _lineSegments.count == 0 {
                    _lineSegments.append(p)
                    let lastSeg = _lineSegments.last!
                    if (_lineSegments.count > 1) {
                        for i in 0..<_lineSegments.count
                        {
                            _lineSegments[i] = _lineSegments[i].applying(valueToPixelMatrix)
                            debugPrint("index = colorIndex _linsegments ==== \(_lineSegments[i])")

                        }
                        context.setStrokeColor(self.hierarchyColors![index].color.cgColor)
                        context.strokeLineSegments(between: _lineSegments)
                        _lineSegments = [lastSeg]
                    }
                    colorIndex = index
                }
            else if index < colorIndex {
                    let diff = colorIndex - index
                    var lastSeg = _lineSegments.last!
                    let slop = (e.y - Double(lastSeg.y)/phaseY)/(e.x - Double(lastSeg.x))
                    for i in 0...diff {
                        let ind = colorIndex - i < 0 ? 0 : colorIndex - i
                        var y:Double,x:Double
                        if i != diff {
                            y = self.hierarchyColors![ind - 1].y
                            x = (y - Double(lastSeg.y)/phaseY) / slop + Double(lastSeg.x)
                        } else {
                            y = e.y
                            x = e.x
                        }
                        
                        _lineSegments.append(CGPoint(x:x,y:y * phaseY))
                        lastSeg = _lineSegments.last!

                        for i in 0..<_lineSegments.count
                        {
                            _lineSegments[i] = _lineSegments[i].applying(valueToPixelMatrix)
                            debugPrint("index < colorIndex _linsegments ==== \(_lineSegments[i])")

                        }
                        context.setStrokeColor(self.hierarchyColors![colorIndex - i].color.cgColor)
                        context.strokeLineSegments(between: _lineSegments)
                        _lineSegments = [lastSeg]
                    }
                    colorIndex = index
                } else {
                    let diff = index - colorIndex
                    var lastSeg = _lineSegments.last!
                    let slop = (e.y - Double(lastSeg.y)/phaseY)/(e.x - Double(lastSeg.x))
                    for i in 0...diff {
                        let ind = colorIndex + i >= limitYCount ? limitYCount - 1 : colorIndex + i
                        var y:Double,x:Double
                        if i != diff {
                            y = self.hierarchyColors![ind].y
                            x = (y - Double(lastSeg.y)/phaseY) / slop + Double(lastSeg.x)
                        } else {
                            y = e.y
                            x = e.x
                        }
                        _lineSegments.append(CGPoint(x:x,y:y * phaseY))
                        lastSeg = _lineSegments.last!
                        for i in 0..<_lineSegments.count
                        {
                            _lineSegments[i] = _lineSegments[i].applying(valueToPixelMatrix)
                            debugPrint("index > colorIndex _linsegments ==== \(_lineSegments[i])")

                        }
                        context.setStrokeColor(self.hierarchyColors![colorIndex + i].color.cgColor)
                        context.strokeLineSegments(between: _lineSegments)
                        _lineSegments = [lastSeg]
                    }
                    colorIndex = index
                }
            }
        } else if dataSet.colors.count > 1
        {
            if _lineSegments.count != pointsPerEntryPair
            {
                // Allocate once in correct size
                _lineSegments = [CGPoint](repeating: CGPoint(), count: pointsPerEntryPair)
            }
            
            for j in stride(from: xBounds.min, through: xBounds.range + xBounds.min, by: 1)
            {
                var e: ChartDataEntry! = dataSet.entryForIndex(j)
                
                if e == nil { continue }
                
                _lineSegments[0].x = CGFloat(e.x)
                _lineSegments[0].y = CGFloat(e.y * phaseY)
                
                if j < xBounds.max
                {
                    e = dataSet.entryForIndex(j + 1)
                    
                    if e == nil { break }
                    
                    if isDrawSteppedEnabled
                    {
                        _lineSegments[1] = CGPoint(x: CGFloat(e.x), y: _lineSegments[0].y)
                        _lineSegments[2] = _lineSegments[1]
                        _lineSegments[3] = CGPoint(x: CGFloat(e.x), y: CGFloat(e.y * phaseY))
                    }
                    else
                    {
                        _lineSegments[1] = CGPoint(x: CGFloat(e.x), y: CGFloat(e.y * phaseY))
                    }
                }
                else
                {
                    _lineSegments[1] = _lineSegments[0]
                }
                
                for i in 0..<_lineSegments.count
                {
                    _lineSegments[i] = _lineSegments[i].applying(valueToPixelMatrix)
                }
                
                if (!viewPortHandler.isInBoundsRight(_lineSegments[0].x))
                {
                    break
                }
                
                // make sure the lines don't do shitty things outside bounds
                if !viewPortHandler.isInBoundsLeft(_lineSegments[1].x)
                    || (!viewPortHandler.isInBoundsTop(_lineSegments[0].y) && !viewPortHandler.isInBoundsBottom(_lineSegments[1].y))
                {
                    continue
                }
                
                // get the color that is set for this line-segment
                context.setStrokeColor(dataSet.color(atIndex: j).cgColor)
                context.strokeLineSegments(between: _lineSegments)
            }
        }
        else
        { // only one color per dataset
            
            var e1: ChartDataEntry!
            var e2: ChartDataEntry!
            
            e1 = dataSet.entryForIndex(xBounds.min)
            
            if e1 != nil
            {
                context.beginPath()
                var firstPoint = true
                
                for x in stride(from: xBounds.min, through: xBounds.range + xBounds.min, by: 1)
                {
                    e1 = dataSet.entryForIndex(x == 0 ? 0 : (x - 1))
                    e2 = dataSet.entryForIndex(x)
                    
                    if e1 == nil || e2 == nil { continue }
                    
                    let pt = CGPoint(
                        x: CGFloat(e1.x),
                        y: CGFloat(e1.y * phaseY)
                        ).applying(valueToPixelMatrix)
                    
                    if firstPoint
                    {
                        context.move(to: pt)
                        firstPoint = false
                    }
                    else
                    {
                        context.addLine(to: pt)
                    }
                    
                    if isDrawSteppedEnabled
                    {
                        context.addLine(to: CGPoint(
                            x: CGFloat(e2.x),
                            y: CGFloat(e1.y * phaseY)
                            ).applying(valueToPixelMatrix))
                    }
                    
                    context.addLine(to: CGPoint(
                        x: CGFloat(e2.x),
                        y: CGFloat(e2.y * phaseY)
                        ).applying(valueToPixelMatrix))
                }
                
                if !firstPoint
                {
                    context.setStrokeColor(dataSet.color(atIndex: 0).cgColor)
                    context.strokePath()
                }
            }
        }
        
        context.restoreGState()
    }
}
