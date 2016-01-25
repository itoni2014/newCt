//
//  ChartStochasView.m
//  sec
//
//  Created by ias_sec on 2015/12/03.
//
//

#import "ChartStochasView.h"
#import "DetailChartView.h"
#import "ChartBox.h"
#import "OhlcBean.h"

@implementation ChartStochasView


- (void)drawRect:(CGRect)rect {
    if([ChartBox sharedInstance].stochasInfoArray.count == 0) {
        return;
    }
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();

    // 最大・最小
//    float max = 0.f;
//    float min = 0.f;
    
//    NSInteger startIdx;
//    NSInteger endIdx;
//    if( [ChartBox sharedInstance].yAxisFixed ){
//        startIdx = 0;
//        endIdx = [ChartBox sharedInstance].ohlcMutableArray.count;
//    }
//    else{
//    }
    
//    NSArray *arr = [ChartBox sharedInstance].stochasInfoArray;
//    NSArray *array = [[ChartBox sharedInstance].stochasInfoArray subarrayWithRange:NSMakeRange(startIdx, endIdx - startIdx)];
    
    
    // スローストキャス
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(STOCHAS_SLOW_PER_D_COLOR[0], STOCHAS_SLOW_PER_D_COLOR[1], STOCHAS_SLOW_PER_D_COLOR[2]), 1.0);
    CGContextSetLineWidth(context, 1);
    
    //開始座標
//    CGFloat pointX = ([ChartBox sharedInstance].candleStickBodyWidth + [ChartBox sharedInstance].candleStickInterval) * startIdx + [ChartBox sharedInstance].candleStickBodyWidth / 2;

    BOOL isFirstPoint = YES;
    CGFloat pointX = [[ChartBox sharedInstance]getStartPositionX]; // [[ChartBox sharedInstance]getValidLeftBorder:startIdx];
    for(NSMutableArray *resultDatas in [ChartBox sharedInstance].stochasInfoArray){
        if (resultDatas != nil && resultDatas.count != 0 && resultDatas[0] != nil && ![resultDatas[0] isEqual: [NSNull null]]) {
            
            CGFloat SlowPerD = [resultDatas[0] floatValue];
            CGFloat pointY = self.detail.subChartStartY + RATE_IN_RANGE(SlowPerD, 0.f, 100.f) * self.detail.subChartValidHeight;
            
            if(isFirstPoint){
                CGContextMoveToPoint(context, pointX, pointY);
                isFirstPoint = NO;
            }
            else{
                CGContextAddLineToPoint(context, pointX, pointY);
                CGContextStrokePath(context);
                CGContextMoveToPoint(context, pointX, pointY);
            }
        }
        
        // 描画座標の更新
        pointX += [ChartBox sharedInstance].candleStickBodyWidth + [ChartBox sharedInstance].candleStickInterval;
    }
    
    
    
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(STOCHAS_SLOW_PER_K_COLOR[0], STOCHAS_SLOW_PER_K_COLOR[1], STOCHAS_SLOW_PER_K_COLOR[2]), 1.0);

//    pointX = ([ChartBox sharedInstance].candleStickBodyWidth + [ChartBox sharedInstance].candleStickInterval) * startIdx + [ChartBox sharedInstance].candleStickBodyWidth / 2;
    pointX = [[ChartBox sharedInstance]getStartPositionX];

    isFirstPoint = YES;
    
//    pointX = [[ChartBox sharedInstance]getValidLeftBorder:startIdx];
    for(NSMutableArray *resultDatas in [ChartBox sharedInstance].stochasInfoArray){
        if (resultDatas != nil && resultDatas.count != 0 && resultDatas[1] != nil && ![resultDatas[1] isEqual: [NSNull null]]) {
            
            CGFloat SlowPerK = [resultDatas[1] floatValue ];
            CGFloat pointY = self.detail.subChartStartY + RATE_IN_RANGE(SlowPerK, 0.f, 100.f) * self.detail.subChartValidHeight;
            
            if(isFirstPoint){
                CGContextMoveToPoint(context, pointX, pointY);
                isFirstPoint = NO;
            }
            else{
                CGContextAddLineToPoint(context, pointX, pointY);
                CGContextStrokePath(context);
                CGContextMoveToPoint(context, pointX, pointY);
            }
        }
        
        // 描画座標の更新
        pointX += [ChartBox sharedInstance].candleStickBodyWidth + [ChartBox sharedInstance].candleStickInterval;
        
    }

}


@end
