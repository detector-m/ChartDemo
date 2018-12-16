//
//  KitbitTodayStepMarkerValueFormatter.m
//  Keep
//
//  Created by 杨虎 on 2018/8/15.
//  Copyright © 2018年 Beijing Calorie Technology Co., Ltd. All rights reserved.
//

#import "KitbitTodayStepMarkerValueFormatter.h"

@interface KitbitTodayStepMarkerValueFormatter()
@property (nonatomic, strong) NSMutableArray<BarChartDataEntry *> *yValues;
@end

@implementation KitbitTodayStepMarkerValueFormatter

- (instancetype)initWithYValues:(NSMutableArray<BarChartDataEntry *> *)yValues {
    self = [super init];
    if (self) {
        _yValues = yValues;
    }
    return self;
}

/**
 * 手环记录每分钟一个步数数据，绘制柱状图每20分钟记一个柱体，一天有(60/20 * 24 + 1)个柱体,多出了的一个刻度是为了显示出00:00这个时间点
 * value 取值： 0 =< value <= 60/20 * 24
 */
- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis {
    NSUInteger time = @(value).unsignedIntegerValue;
    BarChartDataEntry *entry = self.yValues[time];
    return [NSString stringWithFormat:@"%.0f步 %02ld:%02ld-%02ld:%02ld",entry.y,time/3,time%3 * 20,(time+1)/3,(time+1)%3 * 20];
}

- (NSDictionary *)attributeStringForValue:(double)value axis:(ChartAxisBase *)axis {
    NSUInteger time = @(value).unsignedIntegerValue;
    BarChartDataEntry *entry = self.yValues[time];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableArray *array = [NSMutableArray array];
    
    NSDictionary *countDict = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName: [UIFont systemFontOfSize:12]};
    NSString *countText = [NSString stringWithFormat:@"%.0f %@",entry.y,@"步"];
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:countText attributes:countDict];
    [array addObject:@{@"attributes": countDict, @"string": countText}];
    
    NSDictionary *timeDict = @{NSForegroundColorAttributeName:[UIColor colorWithWhite:1 alpha:0.5], NSFontAttributeName: [UIFont systemFontOfSize:12]};
    NSString *timeText = [NSString stringWithFormat:@" %02ld:%02ld-%02ld:%02ld",time/3,time%3 * 20,(time+1)/3,(time+1)%3 * 20];
    [attributeStr appendAttributedString:[[NSAttributedString alloc] initWithString:timeText attributes:timeDict]];
    [array addObject:@{@"attributes": timeDict, @"string": timeText}];
    
    [dict setValue:array forKey:@"attributeArray"];
    [dict setValue:attributeStr forKey:@"attributeStr"];
    return dict.copy;
}
@end
