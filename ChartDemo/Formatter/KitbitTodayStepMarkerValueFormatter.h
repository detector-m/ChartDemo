//
//  KitbitTodayStepMarkerValueFormatter.h
//  Keep
//
//  Created by 杨虎 on 2018/8/15.
//  Copyright © 2018年 Beijing Calorie Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChartDemo-Swift.h"
@import Charts;

@interface KitbitTodayStepMarkerValueFormatter : NSObject <IAxisAttributeValueFormatter>

- (instancetype)initWithYValues:(NSMutableArray<BarChartDataEntry *> *)yValues;

@end
