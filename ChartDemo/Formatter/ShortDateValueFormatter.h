//
//  ShortDateValueFormatter.h
  
//
//  Created by 杨虎 on 2018/8/16.
//  Copyright © 2018年  . All rights reserved.
//

#import <Foundation/Foundation.h>
@import Charts;

@interface ShortDateValueFormatter : NSObject <IChartAxisValueFormatter>

- (instancetype)initWithVisibleLabelsCount:(NSUInteger)count;

- (instancetype)initWithVisibleLabelsCount:(NSUInteger)count allDataCount:(NSUInteger)count;
@end
