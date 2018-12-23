//
//  XYMarkerView.swift
//  ChartsDemo
//  Copyright © 2016 dcg. All rights reserved.
//

import Foundation
import Charts

open class XYMarkerView: BalloonMarker {
    @objc open var xAxisValueFormatter: IAxisValueFormatter?
    fileprivate var yFormatter = NumberFormatter()
    fileprivate var hideYValue = false
    
    @objc public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets,
                xAxisValueFormatter: IAxisValueFormatter) {
        super.init(color: color, font: font, textColor: textColor, insets: insets)
        self.xAxisValueFormatter = xAxisValueFormatter
        yFormatter.minimumFractionDigits = 1
        yFormatter.maximumFractionDigits = 1
    }
    
    @objc public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets,
                      xAxisValueFormatter: IAxisValueFormatter, hideYValue: Bool) {
        super.init(color: color, font: font, textColor: textColor, insets: insets)
        self.xAxisValueFormatter = xAxisValueFormatter
        self.hideYValue = hideYValue
        yFormatter.minimumFractionDigits = 1
        yFormatter.maximumFractionDigits = 1
    }
    
    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        if self.hideYValue == false {
            if let attributeFormatter = self.xAxisValueFormatter as? IAxisAttributeValueFormatter {
                if attributeFormatter.attributeStringForValue != nil {
                    let dict = attributeFormatter.attributeStringForValue!(entry.x, axis: nil)
                    let attributeStr = dict["attributeStr"]
                    let attributeArray = dict["attributeArray"]
                    setAttributeLabel(attributeStr as! NSAttributedString, attrArray:attributeArray as! [[String : Any]])
                    return;
                }
            }
            setLabel("x: " + (xAxisValueFormatter!.stringForValue(entry.x, axis: nil)) + ", y: " + yFormatter.string(from: NSNumber(floatLiteral: entry.y))!)
        } else {
            if let attributeFormatter = self.xAxisValueFormatter as? IAxisAttributeValueFormatter {
                if attributeFormatter.attributeStringForValue != nil {
                    let dict = attributeFormatter.attributeStringForValue!(entry.x, axis: nil)
                    let attributeStr = dict["attributeStr"]
                    let attributeArray = dict["attributeArray"]
                    setAttributeLabel(attributeStr as! NSAttributedString, attrArray:attributeArray as! [[String : Any]])
                    return;
                }
            }
            setLabel((xAxisValueFormatter!.stringForValue(entry.x, axis: nil)))
        }
    }
}
