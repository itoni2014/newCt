

#import "ChartMacdView.h"
#import "DetailChartView.h"
#import "ChartBox.h"
#import "OhlcBean.h"

@implementation ChartMacdView

- (void)drawRect:(CGRect)rect {
    if([ChartBox sharedInstance].macdInfoArray.count == 0) {
        return;
    }
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();

    
    //開始座標
    CGFloat startX = [ChartBox sharedInstance].candleStickBodyWidth / 2;
    
    // 最大・最小
    CGFloat max = 0.f;
    CGFloat min = 0.f;
    NSInteger startIdx;
    NSInteger endIdx;
    if( [ChartBox sharedInstance].yAxisFixed ){
        startIdx = 0;
        endIdx = [ChartBox sharedInstance].ohlcMutableArray.count;
        max = [ChartBox sharedInstance].macdMaxInAll;
        min = [ChartBox sharedInstance].macdMinInAll;
    }
    else{
        max = [ChartBox sharedInstance].macdMaxInRange;
        min = [ChartBox sharedInstance].macdMinInRange;
    }

    CGFloat yPt0 = self.detail.subChartStartY + RATE_IN_RANGE(0.f, min, max) * self.detail.subChartValidHeight;

    
//    NSArray *resultList = [[ChartBox sharedInstance].macdInfoArray subarrayWithRange:NSMakeRange(startIdx, endIdx - startIdx)];
    

    // OSCI
    CGContextSetLineWidth(context, [ChartBox sharedInstance].candleStickBodyWidth);
//    startX = [ChartBox sharedInstance].candleStickBodyWidth / 2;
    
    BOOL isFirstPoint = YES;
    startX = [[ChartBox sharedInstance]getValidLeftBorder:startIdx];

    for(NSMutableArray *resultDatas in [ChartBox sharedInstance].macdInfoArray){
        
        if (resultDatas != nil && ![resultDatas isEqual:[NSNull null]] && resultDatas.count == 3
            && resultDatas[2] != nil && ![resultDatas[2] isEqual: [NSNull null]]) {
            
            CGFloat osci = [resultDatas[2] floatValue ];
            osci < 0 ? CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(MACD_OSCI_DARK_COLOR[0], MACD_OSCI_DARK_COLOR[1], MACD_OSCI_DARK_COLOR[2]), 1.0) :CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(MACD_OSCI_LIGHT_COLOR[0], MACD_OSCI_LIGHT_COLOR[1], MACD_OSCI_LIGHT_COLOR[2]), 1.0);
            
            CGFloat pointY = self.detail.subChartStartY + RATE_IN_RANGE(osci, min, max) * self.detail.subChartValidHeight;

            
            const CGPoint macdStick[] = { CGPointMake(startX, pointY), CGPointMake(startX, yPt0) };
            CGContextStrokeLineSegments(context, macdStick, 2);
            
        }
        
        // 描画座標の更新
        startX += [ChartBox sharedInstance].candleStickBodyWidth + [ChartBox sharedInstance].candleStickInterval;
    }
    
    
    // MACD
    CGContextSetLineWidth(context, 1);
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(MACD_COLOR[0], MACD_COLOR[1], MACD_COLOR[2]), 1.0);
    startX = [ChartBox sharedInstance].candleStickBodyWidth / 2;
    
    isFirstPoint = YES;
    startX = [[ChartBox sharedInstance]getValidLeftBorder:startIdx];
    for(NSMutableArray *resultDatas in [ChartBox sharedInstance].macdInfoArray){
        if (resultDatas != nil && ![resultDatas isEqual:[NSNull null]] && resultDatas.count == 3
            && resultDatas[0] != nil && ![resultDatas[0] isEqual: [NSNull null]]) {
            
            CGFloat pointY = self.detail.subChartStartY + RATE_IN_RANGE([resultDatas[0] floatValue], min, max) * self.detail.subChartValidHeight;
            if(isFirstPoint){
                CGContextMoveToPoint(context, startX,  pointY);
                isFirstPoint = NO;
            }
            else{
                CGContextAddLineToPoint(context, startX, pointY);
                CGContextStrokePath(context);
                CGContextMoveToPoint(context, startX, pointY);
            }
        }
        
        // 描画座標の更新
        startX += [ChartBox sharedInstance].candleStickBodyWidth + [ChartBox sharedInstance].candleStickInterval;
    }
    
    
    // シグナル
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(MACD_SIGNAL_COLOR[0], MACD_SIGNAL_COLOR[1], MACD_SIGNAL_COLOR[2]), 1.0);
    startX = [ChartBox sharedInstance].candleStickBodyWidth / 2;
    
    isFirstPoint = YES;
    startX = [[ChartBox sharedInstance]getValidLeftBorder:startIdx];
    for(NSMutableArray *resultDatas in [ChartBox sharedInstance].macdInfoArray){
        if (resultDatas != nil && ![resultDatas isEqual:[NSNull null]] && resultDatas.count == 3 &&
            resultDatas[1] != nil && ![resultDatas[1] isEqual: [NSNull null]]) {
            CGFloat pointY = self.detail.subChartStartY + RATE_IN_RANGE( [resultDatas[1] floatValue], min, max) * self.detail.subChartValidHeight;
            
            if( isFirstPoint ) {
                CGContextMoveToPoint(context, startX, pointY);
                isFirstPoint = NO;
            }
            else{
                CGContextAddLineToPoint(context, startX, pointY);
                CGContextStrokePath(context);
                CGContextMoveToPoint(context, startX, pointY);
            }
        }
        
        // 描画座標の更新
        startX += [ChartBox sharedInstance].candleStickBodyWidth + [ChartBox sharedInstance].candleStickInterval;
    }

}


@end
