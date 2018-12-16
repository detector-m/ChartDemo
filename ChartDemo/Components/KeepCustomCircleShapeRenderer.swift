//
//  KeepCustomCircleShapeRenderer.swift
//  Keep
//
//  Created by 杨虎 on 2018/8/21.
//  Copyright © 2018年 Beijing Calorie Technology Co., Ltd. All rights reserved.
//

import UIKit
import Charts

class KeepCustomCircleShapeRenderer: NSObject, IShapeRenderer {
    open func renderShape(
        context: CGContext,
        dataSet: IScatterChartDataSet,
        viewPortHandler: ViewPortHandler,
        point: CGPoint,
        color: NSUIColor) {
        let viewRect = viewPortHandler.contentRect
        if point.y >= viewRect.minY + viewRect.height {
            return
        }
        let shapeSize = dataSet.scatterShapeSize
        let shapeHalf = shapeSize / 2.0
        let shapeHoleSizeHalf = dataSet.scatterShapeHoleRadius
        let shapeHoleSize = shapeHoleSizeHalf * 2.0
        let shapeHoleColor = dataSet.scatterShapeHoleColor
        let shapeStrokeSize = (shapeSize - shapeHoleSize) / 2.0
        let shapeStrokeSizeHalf = shapeStrokeSize / 2.0
        
        if shapeHoleSize > 0.0 {
            context.setStrokeColor(color.cgColor)
            context.setLineWidth(shapeStrokeSize)
            var rect = CGRect()
            rect.origin.x = point.x - shapeHoleSizeHalf - shapeStrokeSizeHalf
            rect.origin.y = point.y - shapeHoleSizeHalf - shapeStrokeSizeHalf
            rect.size.width = shapeHoleSize + shapeStrokeSize
            rect.size.height = shapeHoleSize + shapeStrokeSize
            context.strokeEllipse(in: rect)
            
            if let shapeHoleColor = shapeHoleColor {
                context.setFillColor(shapeHoleColor.cgColor)
                rect.origin.x = point.x - shapeHoleSizeHalf
                rect.origin.y = point.y - shapeHoleSizeHalf
                rect.size.width = shapeHoleSize
                rect.size.height = shapeHoleSize
                context.fillEllipse(in: rect)
            }
        } else {
            context.setFillColor(color.cgColor)
            var rect = CGRect()
            rect.origin.x = point.x - shapeHalf
            rect.origin.y = point.y - shapeHalf
            rect.size.width = shapeSize
            rect.size.height = shapeSize
            context.fillEllipse(in: rect)
        }
    }
}
