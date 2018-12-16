//
//  KitbitTodayHeartRateMarkerValueFormatter.m
//  Keep
//
//  Created by 杨虎 on 2018/8/21.
//  Copyright © 2018年 Beijing Calorie Technology Co., Ltd. All rights reserved.
//

#import "KitbitTodayHeartRateMarkerValueFormatter.h"

@interface KitbitTodayHeartRateMarkerValueFormatter()
@property (nonatomic, strong) NSMutableArray<BarChartDataEntry *> *yValues;
@end

@implementation KitbitTodayHeartRateMarkerValueFormatter

- (instancetype)initWithYValues:(NSMutableArray<BarChartDataEntry *> *)yValues {
    self = [super init];
    if (self) {
        _yValues = yValues;
    }
    return self;
}

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis {
    NSUInteger time = @(value).unsignedIntegerValue;
    BarChartDataEntry *entry = self.yValues[time];
    return [NSString stringWithFormat:@"%.0f %@ %02ld:%02ld",entry.y,@"次",time/12,time%12 * 5];
}

- (NSDictionary *)attributeStringForValue:(double)value axis:(ChartAxisBase *)axis {
    NSUInteger time = @(value).unsignedIntegerValue;
    BarChartDataEntry *entry = self.yValues[time];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableArray *array = [NSMutableArray array];
    
    NSDictionary *countDict = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName: [UIFont systemFontOfSize:12]};
    NSString *countText = [NSString stringWithFormat:@"%.0f %@",entry.y,@"次"];
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:countText attributes:countDict];
    [array addObject:@{@"attributes": countDict, @"string": countText}];

    NSDictionary *timeDict = @{NSForegroundColorAttributeName:[UIColor colorWithWhite:1 alpha:0.5], NSFontAttributeName: [UIFont systemFontOfSize:12]};
    NSString *timeText = [NSString stringWithFormat:@" %02ld:%02ld",time/12,time%12 * 5];
    [attributeStr appendAttributedString:[[NSAttributedString alloc] initWithString:timeText attributes:timeDict]];
    [array addObject:@{@"attributes": timeDict, @"string": timeText}];
    
    [dict setValue:array forKey:@"attributeArray"];
    [dict setValue:attributeStr forKey:@"attributeStr"];
    return dict.copy;
}

@end
