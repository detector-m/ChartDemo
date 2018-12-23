//
//
//  Created by 杨虎 on 2018/9/25.
//  Copyright © 2018年. All rights reserved.
//

#import "TodayRestHRValueFormatter.h"

@implementation TodayRestHRValueFormatter
/**
 * 每5分钟一个数据，一天有(60/5 * 24) = 288 个数据,
 * value 取值： 0 =< value < 288
 * X轴每隔6小时显示一个时间点
 */
- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis {
    NSUInteger time = @(ceil(value)).unsignedIntegerValue;
    if (time == 287) {
        return @"24:00";
    }
    return [NSString stringWithFormat:@"%02ld:00",time/12];
}
@end
