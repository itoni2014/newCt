//
//  DetailChartMainView.m
//  sec
//
//  Created by ias_sec on 2015/12/01.
//
//

#import "DetailChartMainView.h"
#import "DetailChartView.h"
#import "ChartBox.h"


@implementation DetailChartMainView

//- (id)initWithFrame:(CGRect)frame{
//    self = [super initWithFrame:frame];
//    if(self){
//
//    }
//    
//    return self;
//}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGFloat minPrice = [ChartBox sharedInstance].yAxisFixed ? [ChartBox sharedInstance].minPriceInAll : [ChartBox sharedInstance].minPriceInRange;
    CGFloat maxPrice = [ChartBox sharedInstance].yAxisFixed ? [ChartBox sharedInstance].maxPriceInAll : [ChartBox sharedInstance].maxPriceInRange;
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetLineWidth(context, 1);

//    //===========================================================================================//
//    //枠線　テスト用
//    CGContextSetLineWidth(context, 0.5);
//    CGContextSetRGBStrokeColor(context, 255/255.0f,255/255.0f,51/255.0f, 1.0); //YELLOW COLOR
//    
//
////    const CGPoint waku1[] = {
////        CGPointMake( 0, 0 ), CGPointMake( 0, rect.size.height  ) };
////    CGContextStrokeLineSegments(context, waku1, 2);
////    const CGPoint waku2[] = {
////        CGPointMake( 0, 0 ), CGPointMake( rect.size.width, 0 ) };
////    CGContextStrokeLineSegments(context, waku2, 2);
////    const CGPoint waku3[] = {
////        CGPointMake( rect.size.width, 0 ), CGPointMake( rect.size.width, rect.size.height) };
////    CGContextStrokeLineSegments(context, waku3, 2);
////    const CGPoint waku4[] = {
////        CGPointMake( 0, rect.size.height ), CGPointMake( rect.size.width, rect.size.height ) };
////    CGContextStrokeLineSegments(context, waku4, 2);
//    
//    const CGPoint waku5[] = { CGPointMake(0, self.detail.startY) , CGPointMake(rect.size.width, self.detail.startY)};
//    CGContextStrokeLineSegments(context, waku5, 2);
//    const CGPoint waku6[] = { CGPointMake(0, self.detail.startY + self.detail.validHeight) , CGPointMake(rect.size.width, self.detail.startY + self.detail.validHeight)};
//    CGContextStrokeLineSegments(context, waku6, 2);
//    
//
//    //    const CGPoint waku1[] = {
//    //        CGPointMake( 1, 1 ), CGPointMake( 1, rect.size.height - 1 ) };
//    //    CGContextStrokeLineSegments(context, waku1, 2);
//    //    const CGPoint waku2[] = {
//    //        CGPointMake( 1, 1 ), CGPointMake( rect.size.width-1, 1 ) };
//    //    CGContextStrokeLineSegments(context, waku2, 2);
//    //    const CGPoint waku3[] = {
//    //        CGPointMake( rect.size.width-1, 1 ), CGPointMake( rect.size.width-1, rect.size.height-1 ) };
//    //    CGContextStrokeLineSegments(context, waku3, 2);
//    //    const CGPoint waku4[] = {
//    //        CGPointMake( 1, rect.size.height-1 ), CGPointMake( rect.size.width-1, rect.size.height-1 ) };
//    //    CGContextStrokeLineSegments(context, waku4, 2);
//
//    //===========================================================================================//


    
    //分割線
    const CGPoint divideLine[] = {
            CGPointMake(0, rect.size.height ), CGPointMake( self.detail.chartWidth, rect.size.height) };
    CGContextStrokeLineSegments(context, divideLine, 2);

    
    
    //    CGContextSetShouldAntialias(context, NO);

    CGContextSetLineWidth(context, LINEWIDTH_DIVIDE);
    CGContextSetRGBStrokeColor(context, COLOR_DIVIDE_LINE, 1.0);
    
    
    NSArray *priceArray = [ChartBox getPricesByHighPrice:maxPrice lowPrice:minPrice];
    
    //Y軸目盛り
    for(NSNumber *price in priceArray){
        CGFloat rate = RATE_IN_RANGE(price.floatValue, minPrice, maxPrice);
        if(rate <= 0.0 || rate >= 1.0 )
            continue;
        
        CGFloat yPos = Y_BEGIN_POINT(rect.size.height) + rate * VALID_HEIGHT_MAIN(rect.size.height);
        
        
        const CGPoint points[] = { CGPointMake(0, yPos), CGPointMake(self.detail.chartWidth, yPos) };
        CGContextStrokeLineSegments(context, points, 2);

        CGPoint pt = CGPointMake(self.detail.chartWidth + 4, yPos - 6);
        [price.stringValue drawAtPoint:pt withAttributes:FONT_ATTRIBUTE(10)];
        
    }
    
    
    //Y軸
    CGContextSetRGBStrokeColor(context, COLOR_YAXIS, 1.0);
    CGContextSetLineWidth(context, 1.0);
    const CGPoint yAxis[] = {
        CGPointMake(self.detail.chartWidth/*+1*/, 0),
        CGPointMake(self.detail.chartWidth/*+1*/, rect.size.height  ) };
    CGContextStrokeLineSegments(context, yAxis, 2);
    
//    //X軸
//    CGContextSetLineWidth(context, 1.0);
//    const CGPoint xAxis[] = {
//        CGPointMake(0, rect.size.height  ),
//        CGPointMake(self.detail.chartWidth/*+1*/, rect.size.height  ) };
//    CGContextStrokeLineSegments(context, xAxis, 2);
}


@end
