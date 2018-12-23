//
//  TodayStepValueFormatter.m

//
//  Created by 杨虎 on 2018/8/14.
//  Copyright © 2018年  . All rights reserved.
//

#import "TodayStepValueFormatter.h"

@implementation TodayStepValueFormatter

/**
 * 每分钟一个数据，绘制柱状图每20分钟记一个柱体，一天有(60/20 * 24 + 1)个柱体,多出了的一个刻度是为了显示出00:00这个时间点
 * value 取值： 0 =< value <= 60/20 * 24
 * X轴每隔6小时显示一个时间点
 */
- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis {
    NSUInteger time = @(ceil(value)).unsignedIntegerValue;
    return [NSString stringWithFormat:@"%02ld:00",time/3];
}

@end
