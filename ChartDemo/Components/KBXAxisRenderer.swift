//
//  KBXAxisRenderer.swift
//  Keep
//
//  Created by 杨虎 on 2018/10/30.
//  Copyright © 2018年 Beijing Calorie Technology Co., Ltd. All rights reserved.
//
import CoreGraphics
import Foundation
import Charts

class KBXAxisRenderer: XAxisRenderer {
    
    @objc open var selectedEntryX:NSNumber?
    
    @objc open var selectedXLabelTextColor:UIColor?
    
    @objc open var selectedXLabelFont:UIFont?
    
    override func drawLabels(context: CGContext, pos: CGFloat, anchor: CGPoint) {
        guard
            let xAxis = self.axis as? XAxis,
            let transformer = self.transformer
            else { return }
        
        #if os(OSX)
        let paraStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        #else
        let paraStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        #endif
        paraStyle.alignment = .center
        
        var labelAttrs: [NSAttributedStringKey : Any] = [NSAttributedStringKey.font: xAxis.labelFont,
                                                         NSAttributedStringKey.foregroundColor: xAxis.labelTextColor,
                                                         NSAttributedStringKey.paragraphStyle: paraStyle]
        let labelRotationAngleRadians = xAxis.labelRotationAngle.degreesToRadians
        
        let centeringEnabled = xAxis.isCenterAxisLabelsEnabled
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        var labelMaxSize = CGSize()
        
        if xAxis.isWordWrapEnabled
        {
            labelMaxSize.width = xAxis.wordWrapWidthPercent * valueToPixelMatrix.a
        }
        
        let entries = xAxis.entries
        
        for i in stride(from: 0, to: entries.count, by: 1)
        {
            if centeringEnabled
            {
                position.x = CGFloat(xAxis.centeredEntries[i])
            }
            else
            {
                position.x = CGFloat(entries[i])
            }
            
            position.y = 0.0
            position = position.applying(valueToPixelMatrix)
            
            if viewPortHandler.isInBoundsX(position.x)
            {
                let label = xAxis.valueFormatter?.stringForValue(xAxis.entries[i], axis: xAxis) ?? ""
                
                let labelns = label as NSString
                
                if xAxis.isAvoidFirstLastClippingEnabled
                {
                    // avoid clipping of the last
                    if i == xAxis.entryCount - 1 && xAxis.entryCount > 1
                    {
                        let width = labelns.boundingRect(with: labelMaxSize, options: .usesLineFragmentOrigin, attributes: labelAttrs, context: nil).size.width
                        
                        if width > viewPortHandler.offsetRight * 2.0
                            && position.x + width > viewPortHandler.chartWidth
                        {
                            position.x -= width / 2.0
                        }
                    }
                    else if i == 0
                    { // avoid clipping of the first
                        let width = labelns.boundingRect(with: labelMaxSize, options: .usesLineFragmentOrigin, attributes: labelAttrs, context: nil).size.width
                        position.x += width / 2.0
                    }
                }
                
                if self.selectedXLabelTextColor != nil,self.selectedEntryX?.doubleValue == xAxis.entries[i]
                {
                    labelAttrs[NSAttributedStringKey.foregroundColor] = self.selectedXLabelTextColor
                }
                else
                {
                    labelAttrs[NSAttributedStringKey.foregroundColor] = axis?.labelTextColor
                }
                
                if self.selectedXLabelFont != nil,self.selectedEntryX?.doubleValue == xAxis.entries[i]
                {
                    labelAttrs[NSAttributedStringKey.font] = self.selectedXLabelFont
                }
                else
                {
                    labelAttrs[NSAttributedStringKey.font] = axis?.labelFont
                }
                
                drawLabel(context: context,
                          formattedLabel: label,
                          x: position.x,
                          y: pos,
                          attributes: labelAttrs,
                          constrainedToSize: labelMaxSize,
                          anchor: anchor,
                          angleRadians: labelRotationAngleRadians)
            }
        }
    }
}
