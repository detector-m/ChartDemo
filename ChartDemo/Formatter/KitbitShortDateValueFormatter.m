//
//  KitbitShortDateValueFormatter.m
//  Keep
//
//  Created by 杨虎 on 2018/8/16.
//  Copyright © 2018年 Beijing Calorie Technology Co., Ltd. All rights reserved.
//

#import "KitbitShortDateValueFormatter.h"

@interface KitbitShortDateValueFormatter()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, assign) NSUInteger labelCount;

@property (nonatomic, assign) NSUInteger allDataCount;

@end

@implementation KitbitShortDateValueFormatter

- (instancetype)initWithVisibleLabelsCount:(NSUInteger)count {
    self = [super init];
    if (self) {
        _labelCount = count;
    }
    return self;
}

- (instancetype)initWithVisibleLabelsCount:(NSUInteger)count allDataCount:(NSUInteger)dataCount {
    self = [self initWithVisibleLabelsCount:count];
    self.allDataCount = dataCount;
    return self;
}

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis {
    NSUInteger count = self.allDataCount > 0 ? self.allDataCount : axis.labelCount;
    NSUInteger time = @(value).unsignedIntegerValue;
    if (time > count - self.labelCount/2 - 1) {
        return @"";
    } else if (time == count - self.labelCount/2 - 1) {
        return @"今日";
    }
    NSTimeInterval currentInterval = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval preInterval = currentInterval-(count - self.labelCount/2 - 1 - time)*3600*24;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:preInterval];
    NSString *dateStr = [self.dateFormatter stringFromDate:date];
    return dateStr;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"M/dd";
        _dateFormatter.timeZone = [NSTimeZone systemTimeZone];
    }
    return _dateFormatter;
}

@end
