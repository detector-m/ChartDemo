//
//
//  Created by 杨虎 on 2018/8/21.
//  Copyright © 2018年  . All rights reserved.
//

#import <Foundation/Foundation.h>
@import Charts;
#import "ChartDemo-Swift.h"

@interface TodayHeartRateMarkerValueFormatter : NSObject <IAxisAttributeValueFormatter>

- (instancetype)initWithYValues:(NSMutableArray<BarChartDataEntry *> *)yValues;

@end
