

#import "ChartRsiView.h"
#import "DetailChartView.h"
#import "ChartBox.h"
#import "OhlcBean.h"

@implementation ChartRsiView

- (void)drawRect:(CGRect)rect {
    if( [ChartBox sharedInstance].rsiInfoArray.count == 0 ){
        return;
    }

    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    

    
//    NSInteger startIdx;
//    NSInteger endIdx;
//    if( [ChartBox sharedInstance].yAxisFixed ){
//        startIdx = 0;
//        endIdx = [ChartBox sharedInstance].ohlcMutableArray.count;
//    }
//    else{
//    }
    

    
    //開始座標
//    CGFloat pointX = ([ChartBox sharedInstance].candleStickBodyWidth + [ChartBox sharedInstance].candleStickInterval) * startIdx + [ChartBox sharedInstance].candleStickBodyWidth / 2;

    CGContextSetLineWidth(context, 1);
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(RSI_COLOR[0], RSI_COLOR[1], RSI_COLOR[2]), 1.0);
    
    
//    NSArray *array = [[ChartBox sharedInstance].rsiInfoArray subarrayWithRange:NSMakeRange(startIdx, endIdx - startIdx)];
    
    BOOL isFirstPoint = YES;
    CGFloat pointX = [[ChartBox sharedInstance]getStartPositionX]; // getValidLeftBorder:startIdx];
    
    for(NSDecimalNumber *number in [ChartBox sharedInstance].rsiInfoArray){
        if(![number isEqual:[NSNull null]]){
            CGFloat pointY = self.detail.subChartStartY + RATE_IN_RANGE(number.floatValue, 0.f, 100.f) * self.detail.subChartValidHeight;
            if( isFirstPoint ){
                CGContextMoveToPoint(context, pointX, pointY);
                isFirstPoint = NO;
            }
            else{
                CGContextAddLineToPoint(context, pointX, pointY);
                CGContextStrokePath(context);
                CGContextMoveToPoint(context, pointX, pointY);
            }
            
        }
        
        pointX += [[ChartBox sharedInstance]getStickUnitWidth];
    }
    

}


@end
