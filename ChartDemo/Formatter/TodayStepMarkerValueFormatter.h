//
//  TodayStepMarkerValueFormatter.h
  
//
//  Created by 杨虎 on 2018/8/15.
//  Copyright © 2018年  . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChartDemo-Swift.h"
@import Charts;

@interface TodayStepMarkerValueFormatter : NSObject <IAxisAttributeValueFormatter>

- (instancetype)initWithYValues:(NSMutableArray<BarChartDataEntry *> *)yValues;

@end
