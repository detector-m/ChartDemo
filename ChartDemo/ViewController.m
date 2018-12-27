//
//  ViewController.m
//  ChartDemo
//
//  Created by young on 2018/12/15.
//  Copyright © 2018年 young. All rights reserved.
//

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

#define YHChartWidth SCREENWIDTH
#define YHPerBarWidth (YHChartWidth / YHVisibleHistorysCount)

@import Charts;
#import "ViewController.h"
#import "ChartDemo-Swift.h"
#import "ShortDateValueFormatter.h"
#import "TodayStepMarkerValueFormatter.h"

static const CGFloat YHChartHeight = 343;
static const NSUInteger YHVisibleHistorysCount = 9;
static const NSUInteger YHFetchNumber = 10;

@interface ViewController () <UIScrollViewDelegate,ChartViewDelegate,YHBarChartRendererDelegate>
@property (nonatomic, strong) NSMutableArray<BarChartDataEntry *> *historys;
@property (nonatomic, strong) UIScrollView *containerScrollView;
@property (nonatomic, strong) CombinedChartView *stepHistoryChart;

@property (nonatomic, strong) NSMutableArray *stepDatas; // 已加载的数据

@property (nonatomic, assign) CGFloat lastOffsetToRightEdge; // 用于数据源增加时，使 containerScrollView 滚动到上一次偏移的位置

@property (nonatomic, assign) BOOL loading;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _containerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, YHChartWidth, YHChartHeight)];
    _containerScrollView.showsVerticalScrollIndicator = NO;
    _containerScrollView.showsHorizontalScrollIndicator = NO;
    _containerScrollView.alwaysBounceVertical = NO;
    _containerScrollView.alwaysBounceHorizontal = YES;
    _containerScrollView.delegate = self;
    _containerScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.containerScrollView];
    
    self.lastOffsetToRightEdge = YHChartWidth;
    
    UIImage *image = [UIImage imageNamed:@"icon_data_center_data_chart_arrow"];
    UIImageView *arrowView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:arrowView];
    arrowView.frame = CGRectMake(SCREENWIDTH / 2.0 - image.size.width / 2, CGRectGetMaxY(_containerScrollView.frame) - image.size.height, image.size.width, image.size.height);
    
    [self addData];
}

- (void)addData {
    if (self.loading) return;
    self.loading = YES;
    
    if (!_stepDatas) {
        _stepDatas = [NSMutableArray array];
    }
    NSUInteger count = YHFetchNumber;
    for (NSUInteger i = 0; i < count; i++) {
        NSUInteger random = arc4random_uniform(5000);
        [_stepDatas addObject:@(random)];
    }
    
    [self addRandomHistorys];

    if (self.stepHistoryChart) {
        self.lastOffsetToRightEdge = self.containerScrollView.contentSize.width - self.containerScrollView.contentOffset.x;
    }
    [self updateHistoryChartView];
    CGFloat offset = self.containerScrollView.contentSize.width - self.lastOffsetToRightEdge;
    [self.containerScrollView setContentOffset:CGPointMake(offset, 0) animated:NO];
    [self adjustContentOffset:self.containerScrollView];
    self.loading = NO;
}


- (void)updateHistoryChartView {
    _containerScrollView.contentSize = CGSizeMake(self.historys.count * YHPerBarWidth, YHChartHeight);
    _containerScrollView.contentOffset = CGPointMake((self.historys.count-YHVisibleHistorysCount) * YHPerBarWidth, 0);
    _containerScrollView.backgroundColor = [UIColor blackColor];
    CGRect chartRect = CGRectMake(0, 0, _containerScrollView.contentSize.width, _containerScrollView.contentSize.height);
    if (!_stepHistoryChart) {
        _stepHistoryChart = [[CombinedChartView alloc] initWithFrame:chartRect];
        [_stepHistoryChart setScaleEnabled:NO];
        _stepHistoryChart.drawOrder = @[@(CombinedChartDrawOrderLine), @(CombinedChartDrawOrderBar)]; // 绘制层级

        ChartXAxis *xAxis = _stepHistoryChart.xAxis;
        xAxis.labelPosition = XAxisLabelPositionTop;
        xAxis.labelFont = [UIFont systemFontOfSize:12];
        xAxis.drawGridLinesEnabled = NO;
        xAxis.drawAxisLineEnabled = NO;
        xAxis.spaceMax = 0.5; // 坐标轴额外的偏移
        xAxis.spaceMin = xAxis.spaceMax;
        xAxis.enabled = YES;
        xAxis.labelTextColor = [UIColor colorWithWhite:1 alpha:0.6];

        ChartXAxisRenderer *render = _stepHistoryChart.xAxisRenderer;
        YHXAxisRenderer *xAxisRenderer = [[YHXAxisRenderer alloc] initWithViewPortHandler:render.viewPortHandler xAxis:(ChartXAxis *)(render.axis) transformer:render.transformer];
        xAxisRenderer.selectedXLabelFont = [UIFont systemFontOfSize:14];
        xAxisRenderer.selectedXLabelTextColor = [UIColor whiteColor];
        _stepHistoryChart.xAxisRenderer = xAxisRenderer;
        
        TodayStepMarkerValueFormatter *markerFormatter = [[TodayStepMarkerValueFormatter alloc] initWithYValues:self.historys];
        XYMarkerView *marker = [[XYMarkerView alloc]
                                    initWithColor: [UIColor grayColor]
                                    font: [UIFont systemFontOfSize:12]
                                    textColor: [UIColor whiteColor]
                                    insets: UIEdgeInsetsMake(8.0, 8.0, 16.6, 8.0)
                                    xAxisValueFormatter: markerFormatter
                                    hideYValue:YES];
        marker.chartView = _stepHistoryChart;
        marker.minimumSize = CGSizeMake(94.5, 42.1);
        _stepHistoryChart.marker = marker;

        _stepHistoryChart.delegate = self;
        _stepHistoryChart.drawBarShadowEnabled = NO;
        _stepHistoryChart.drawValueAboveBarEnabled = NO;
        _stepHistoryChart.leftAxis.enabled = NO;
        _stepHistoryChart.leftAxis.axisMinimum = 0;
        _stepHistoryChart.rightAxis.enabled = NO;
        _stepHistoryChart.legend.enabled = NO;
        _stepHistoryChart.chartDescription = nil;
        _stepHistoryChart.dragEnabled = NO;
        _stepHistoryChart.extraTopOffset = 5;
        _stepHistoryChart.minOffset = 0;
        [self.containerScrollView addSubview:self.stepHistoryChart];
    }
    _stepHistoryChart.frame = chartRect;
    ChartXAxis *xAxis = _stepHistoryChart.xAxis;
    xAxis.axisMaxLabels = self.historys.count;
    xAxis.labelCount = self.historys.count;
    xAxis.valueFormatter = [[ShortDateValueFormatter alloc] initWithVisibleLabelsCount:YHVisibleHistorysCount allDataCount:self.historys.count];

    CombinedChartData *chartData = [[CombinedChartData alloc] init];
    chartData.lineData = [self generateLineData];
    chartData.barData = [self generateBarData];

    _stepHistoryChart.data = chartData;
    CombinedChartRenderer *combineRender = (CombinedChartRenderer *)_stepHistoryChart.renderer;
    BarChartRenderer *barRender = (BarChartRenderer *)[combineRender getSubRendererWithIndex:1];
    YHBarChartRenderer *yhRender = [[YHBarChartRenderer alloc] initWithDataProvider:_stepHistoryChart animator:barRender.animator viewPortHandler:barRender.viewPortHandler];
    yhRender.delegate = self;
    combineRender.subRenderers = @[[combineRender getSubRendererWithIndex:0],yhRender];

    _stepHistoryChart.leftAxis.axisMaximum = chartData.yMax+10;
}

- (LineChartData *)generateLineData {
    LineChartData *d = [[LineChartData alloc] init];
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    for (int index = 0; index < self.stepDatas.count; index++){
        NSUInteger step = [self.stepDatas[index] integerValue];
        [entries addObject:[[ChartDataEntry alloc] initWithX:index y:step]];
    }

    LineChartDataSet *set = [[LineChartDataSet alloc] initWithValues:entries label:@""];
    set.lineWidth = 1;
    set.drawCirclesEnabled = NO;
    set.mode = LineChartModeStepped;
    set.drawVerticalHighlightIndicatorEnabled = NO;
    set.lineDashLengths = @[@5,@10,@15];
    set.drawValuesEnabled = NO;
    set.highlightEnabled = NO;
    set.axisDependency = AxisDependencyLeft;
    set.colors = @[[UIColor whiteColor],[UIColor redColor],[UIColor blueColor]];
    [d addDataSet:set];
    return d;
}

- (BarChartData *)generateBarData {
    BarChartDataSet *set = [[BarChartDataSet alloc] initWithValues:self.historys label:@""];
    set.axisDependency = AxisDependencyLeft;
    set.drawValuesEnabled = NO;
    BarChartData *d = [[BarChartData alloc] initWithDataSets:@[set]];
    d.barWidth = 0.9f;
    set.highlightColor = [UIColor greenColor];
    set.highlightAlpha = 1;
    return d;
}


- (void)addRandomHistorys {
    if (!_historys) {
        _historys = [NSMutableArray array];
    } else {
        [_historys removeAllObjects];
    }
    for (NSUInteger i = 0; i < _stepDatas.count; i++) {
        NSUInteger random = arc4random_uniform(5000);
        [_historys addObject:[[BarChartDataEntry alloc] initWithX:@(i).doubleValue y:@(random).doubleValue]];
    }
    NSUInteger count = self.stepDatas.count;
    for (NSInteger i = count; i < count+YHVisibleHistorysCount/2; i++) {
        [_historys addObject:[[BarChartDataEntry alloc] initWithX:@(i).doubleValue y:@(0).doubleValue]];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x < -YHPerBarWidth) {
        [self addData];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self adjustContentOffset:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self adjustContentOffset:scrollView];
    }
}

- (void)adjustContentOffset:(UIScrollView *)scrollV {
    CGFloat ratio = scrollV.contentOffset.x / YHPerBarWidth;
    NSUInteger tempValue = roundf(ratio);
    [scrollV setContentOffset:CGPointMake(tempValue * YHPerBarWidth, 0) animated:YES];
    NSUInteger selected = tempValue + YHVisibleHistorysCount/2;

    BarChartDataEntry *entry = self.historys[selected];
    ChartHighlight *high = [[ChartHighlight alloc] initWithX:@(selected).doubleValue y:entry.y dataSetIndex:0 dataIndex:1];

    [self.stepHistoryChart highlightValue:nil];
    [self.stepHistoryChart highlightValue:high callDelegate:YES];
}

- (void)chartValueSelected:(ChartViewBase * _Nonnull)chartView entry:(ChartDataEntry * _Nonnull)entry highlight:(ChartHighlight * _Nonnull)highlight {
    if ([chartView isKindOfClass:[BarLineChartViewBase class]]) {
        BarLineChartViewBase *baseChart = (BarLineChartViewBase *)chartView;
        YHXAxisRenderer *xAxisRenderer = (YHXAxisRenderer *)(baseChart.xAxisRenderer);
        xAxisRenderer.selectedEntryX = @(highlight.x);
    }

    NSInteger dataIndex = @(highlight.x).integerValue;
    if (dataIndex > self.historys.count - YHVisibleHistorysCount/2 - 1) {
        [chartView highlightValue:nil];
        return;
    }
    CGFloat destinationOffset = dataIndex * YHPerBarWidth + YHPerBarWidth/2.0 - YHChartWidth/2.0;
    if (destinationOffset + YHChartWidth > self.containerScrollView.contentSize.width) {
        destinationOffset = self.containerScrollView.contentSize.width - YHChartWidth;
    }
    if (destinationOffset < 0) destinationOffset = 0;
    [self.containerScrollView setContentOffset:CGPointMake(destinationOffset, 0) animated:YES];
    self.lastOffsetToRightEdge = self.containerScrollView.contentSize.width - destinationOffset;
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView {
    if ([chartView isKindOfClass:[BarLineChartViewBase class]]) {
        BarLineChartViewBase *baseChart = (BarLineChartViewBase *)chartView;
        YHXAxisRenderer *xAxisRenderer = (YHXAxisRenderer *)(baseChart.xAxisRenderer);
        xAxisRenderer.selectedEntryX = nil;
    }
}

- (void)drawBarChartShapeWithContext:(CGContextRef)context barRect:(CGRect)barRect {
    CGMutablePathRef path = CGPathCreateMutable();
    [self drawBaseBarShapeWithContext:context barRect:barRect path:path];
    [self drawLinearGradient:context path:path isVerticalGredient:YES];
}

- (void)drawBaseBarShapeWithContext:(CGContextRef)context barRect:(CGRect)barRect path:(CGMutablePathRef)path {
    CGFloat y = barRect.origin.y;
    CGFloat x = barRect.origin.x;
    CGFloat barWidth = barRect.size.width;
    CGFloat halfBarWidth = barWidth/2.0;
    CGFloat barHeight = barRect.size.height;

    if (!path) {
        path = CGPathCreateMutable();
    }
    if (barHeight >= halfBarWidth) {
        CGPathMoveToPoint(path, nil, x, y+halfBarWidth);
        CGPathAddArc(path, nil, x+halfBarWidth, y+halfBarWidth, halfBarWidth, 0, M_PI, YES);
        CGPathMoveToPoint(path, nil, x+barWidth, y+halfBarWidth);
        CGPathAddLineToPoint(path, nil, x+barWidth, y+barHeight);
        CGPathAddLineToPoint(path, nil, x, y+barHeight);
        CGPathAddLineToPoint(path, nil, x, y+halfBarWidth);
    } else {
        CGFloat radius = (pow(barHeight, 2)+pow(halfBarWidth, 2))/2.0/barHeight;
        CGFloat angle = acos(halfBarWidth/radius);
        CGPathAddArc(path, nil, x+halfBarWidth, y+radius,radius, -angle, -(M_PI-angle), YES);
        CGPathAddLineToPoint(path, nil, x+barWidth, y+barHeight);
    }

    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CGContextSaveGState(context);
}

- (void)drawBarChartHighlightShapeWithContext:(CGContextRef)context barRect:(CGRect)barRect {
    [self drawBaseBarShapeWithContext:context barRect:barRect path:nil];
    CGContextRestoreGState(context);
}

- (void)drawLinearGradient:(CGContextRef)context path:(CGMutablePathRef)path isVerticalGredient:(BOOL)isVerticalGredient {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = {0.0, 0.5};
    NSArray *colors = @[(__bridge id) [UIColor redColor].CGColor, (__bridge id) [UIColor greenColor].CGColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    CGRect pathRect = CGPathGetBoundingBox(path);
    CGPoint startPoint, endPoint;
    if (isVerticalGredient) {
        startPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMaxY(pathRect));
        endPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMinY(pathRect));
    } else {
        startPoint = CGPointMake(CGRectGetMinX(pathRect), CGRectGetMidY(pathRect));
        endPoint = CGPointMake(CGRectGetMaxX(pathRect), CGRectGetMidY(pathRect));
    }
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);

    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}


@end
