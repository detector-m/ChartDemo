//
//  IAxisAttributeValueFormatter.swift
  
//
//  Created by 杨虎 on 2018/10/30.
//  Copyright © 2018年  . All rights reserved.
//

import Foundation
import Charts

@objc public protocol IAxisAttributeValueFormatter: IAxisValueFormatter {
    
    @objc optional func attributeStringForValue(_ value: Double, axis: AxisBase?) -> NSDictionary
    
}
