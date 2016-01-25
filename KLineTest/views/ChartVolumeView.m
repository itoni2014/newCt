

#import "ChartVolumeView.h"
#import "DetailChartView.h"
#import "ChartBox.h"
#import "OhlcBean.h"

@implementation ChartVolumeView

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    if([ChartBox sharedInstance].ohlcMutableArray.count == 0)
        return;
    
//    NSInteger startIdx;
//    NSInteger endIdx;
    CGFloat maxVolume;
    
    if( [ChartBox sharedInstance].yAxisFixed ){
        maxVolume = [ChartBox sharedInstance].maxVolumeInAll;
//        startIdx = 0;
//        endIdx = [ChartBox sharedInstance].ohlcMutableArray.count;
        
    }
    else{
        maxVolume = [ChartBox sharedInstance].maxVolumeInRange;
    }
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, 0/255.f, 0/255.f, 0/255.f, 1.0); //黒色
    CGContextSetLineWidth(context, [ChartBox sharedInstance].candleStickBodyWidth);
    
//    CGFloat pointX = ([ChartBox sharedInstance].candleStickBodyWidth + [ChartBox sharedInstance].candleStickInterval) * startIdx + [ChartBox sharedInstance].candleStickBodyWidth / 2; //開始座標
//    pointX = [[ChartBox sharedInstance]getValidLeftBorder:startIdx];
    CGFloat pointX = [[ChartBox sharedInstance]getStartPositionX];

//    for(NSInteger i = startIdx; i < endIdx; i++){
//        OhlcBean *bean = [[ChartBox sharedInstance].ohlcMutableArray objectAtIndex:i];
    for(OhlcBean *bean in [ChartBox sharedInstance].ohlcMutableArray ){
    
//        if (stockInfo.openPrice.floatValue >= stockInfo.closePrice.floatValue)
//            CGContextSetRGBStrokeColor(context, COLOR_CANDLESTICK_FALL, 1.0);
//        else
//            CGContextSetRGBStrokeColor(context, COLOR_CANDLESTICK_RISE, 1.0);
        
        const CGPoint volumeStick[] = {
            CGPointMake(pointX, self.detail.subChartStartY + RATE_WITH_NUMBER(bean.turnover, maxVolume) * self.detail.subChartValidHeight),
            CGPointMake(pointX, rect.size.height) };
        
        CGContextStrokeLineSegments(context, volumeStick, 2);
        
        pointX += [[ChartBox sharedInstance]getStickUnitWidth];
    }
    
}


@end