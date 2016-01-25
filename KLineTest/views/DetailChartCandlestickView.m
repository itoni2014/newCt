
#import "DetailChartCandlestickView.h"
#import "ChartBox.h"
#import "OhlcBean.h"
#import "DetailChartView.h"

@implementation DetailChartCandlestickView

- (void)drawRect:(CGRect)rect {
    
    if([ChartBox sharedInstance].ohlcMutableArray.count == 0)
        return;

    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    CGFloat maxPrice;
    CGFloat minPrice;
    NSInteger startIdx;
    NSInteger endIdx;
    NSInteger maxPriceIdx = [ChartBox sharedInstance].maxPriceIdxInRange;
    NSInteger minPriceIdx = [ChartBox sharedInstance].minPriceIdxInRange;
    CGFloat maxPrice0 = [ChartBox sharedInstance].maxPriceInRange;
    CGFloat minPrice0 = [ChartBox sharedInstance].minPriceInRange;
//    self.maxPrice4ValInAll = self.maxPriceInAll;
//    self.minPrice4ValInAll = self.minPriceInAll;
    CGFloat maxPriceDisp;
    CGFloat minPriceDisp;

    if( [ChartBox sharedInstance].yAxisFixed ){
        maxPrice = [ChartBox sharedInstance].maxPriceInAll;
        minPrice = [ChartBox sharedInstance].minPriceInAll;
        startIdx = 0;
        endIdx = [ChartBox sharedInstance].ohlcMutableArray.count;
        minPriceIdx = [ChartBox sharedInstance].minPriceIdxInAll;
        maxPriceIdx = [ChartBox sharedInstance].maxPriceIdxInAll;
        maxPriceDisp = [ChartBox sharedInstance].maxPriceInAllDisp;
        minPriceDisp = [ChartBox sharedInstance].minPriceInAllDisp;
    }
    else{
        maxPrice = [ChartBox sharedInstance].maxPriceInRange;
        minPrice = [ChartBox sharedInstance].minPriceInRange;
        //        minPriceIdx = self.vc.minPrice0Idx;
        //        maxPriceIdx = self.vc.maxPrice0Idx;
    }
    
    
//    //===========================================================================================//
//    //枠線　テスト用
//    CGContextSetRGBStrokeColor(context, 255/255.0f,0/255.0f,0/255.0f, 1.0);
//    
//    const CGPoint waku1[] = {
//        CGPointMake( 0, 0 ), CGPointMake( 0, rect.size.height  ) };
//    CGContextStrokeLineSegments(context, waku1, 2);
//    const CGPoint waku2[] = {
//        CGPointMake( 0, 0 ), CGPointMake( rect.size.width, 0 ) };
//    CGContextStrokeLineSegments(context, waku2, 2);
//    const CGPoint waku3[] = {
//        CGPointMake( rect.size.width, 0 ), CGPointMake( rect.size.width, rect.size.height) };
//    CGContextStrokeLineSegments(context, waku3, 2);
//    const CGPoint waku4[] = {
//        CGPointMake( 0, rect.size.height ), CGPointMake( rect.size.width, rect.size.height ) };
//    CGContextStrokeLineSegments(context, waku4, 2);
//    //===========================================================================================//

    
    float height = rect.size.height;
    float validHeight = VALID_HEIGHT_MAIN(rect.size.height);
    
    //開始X座標
    CGFloat startX = [[ChartBox sharedInstance]getStartPositionX]; // [[ChartBox sharedInstance] getValidLeftBorder: startIdx];
    
//    for(NSInteger i = startIdx; i < endIdx; i++){
//        OhlcBean *bean = [[ChartBox sharedInstance].ohlcMutableArray objectAtIndex:i];
    for(OhlcBean *bean in [ChartBox sharedInstance].ohlcMutableArray){
    
        bean.openPrice.floatValue <= bean.closePrice.floatValue ?
        CGContextSetRGBStrokeColor(context, COLOR_CANDLESTICK_RISE, 1.0) :
        CGContextSetRGBStrokeColor(context, COLOR_CANDLESTICK_FALL, 1.0);
        
        CGContextSetLineWidth(context, [ChartBox sharedInstance].candleStickBodyWidth/3.33);
        const CGPoint shadow[] = {
            CGPointMake(startX, Y_BEGIN_POINT(rect.size.height) + RATE_IN_RANGE(bean.highPrice.floatValue, minPrice, maxPrice) * VALID_HEIGHT_MAIN(rect.size.height)),
            CGPointMake(startX, Y_BEGIN_POINT(rect.size.height) + RATE_IN_RANGE(bean.lowPrice.floatValue, minPrice, maxPrice) * VALID_HEIGHT_MAIN(rect.size.height)) };
        CGContextStrokeLineSegments(context, shadow, 2);
        
        CGContextSetLineWidth(context, [ChartBox sharedInstance].candleStickBodyWidth);
        const CGPoint body[] = {
            CGPointMake(startX, Y_BEGIN_POINT(rect.size.height) + RATE_IN_RANGE(bean.openPrice.floatValue, minPrice, maxPrice) * VALID_HEIGHT_MAIN(rect.size.height)),
            CGPointMake(startX, Y_BEGIN_POINT(rect.size.height) + RATE_IN_RANGE(bean.closePrice.floatValue, minPrice, maxPrice) * VALID_HEIGHT_MAIN(rect.size.height)) };
        CGContextStrokeLineSegments(context, body, 2);
        
        startX += [[ChartBox sharedInstance]getStickUnitWidth];
    }
    
    
    //最高値・最安値の表示
    CGFloat maxPosX = [[ChartBox sharedInstance]getValidLeftBorder:maxPriceIdx]-8;// maxPriceIdx * ([ChartBox sharedInstance].candleStickBodyWidth + [ChartBox sharedInstance].candleStickInterval) - 8;
//    CGFloat maxPosY = Y_BEGIN_POINT(rect.size.height);
    CGFloat maxPosY = Y_BEGIN_POINT(rect.size.height) + RATE_IN_RANGE(maxPriceDisp, minPrice, maxPrice) * VALID_HEIGHT_MAIN(rect.size.height);
    NSString *strMax = [NSString stringWithFormat:@"%.2f", maxPriceDisp];
    CGPoint maxPoint = CGPointMake(maxPosX, maxPosY - 10);
    [strMax drawAtPoint: maxPoint withAttributes: FONT_ATTRIBUTE(8)];
    
    CGFloat minPosX = [[ChartBox sharedInstance]getValidLeftBorder:minPriceIdx];//  minPriceIdx * ([ChartBox sharedInstance].candleStickBodyWidth + [ChartBox sharedInstance].candleStickInterval) /*- 8*/;
    minPosX = minPosX < 0 ? 0 : minPosX;
//    CGFloat minPosY = Y_BEGIN_POINT(rect.size.height) + VALID_HEIGHT_MAIN(rect.size.height) - 3;
    CGFloat minPosY = Y_BEGIN_POINT(rect.size.height) + RATE_IN_RANGE(minPriceDisp, minPrice, maxPrice) * VALID_HEIGHT_MAIN(rect.size.height) - 3;
    NSString *strMin = [NSString stringWithFormat:@"%.2f", minPriceDisp];
    CGPoint minPoint = CGPointMake(minPosX, minPosY);
    [strMin drawAtPoint: minPoint withAttributes:FONT_ATTRIBUTE(8)];
}


@end
