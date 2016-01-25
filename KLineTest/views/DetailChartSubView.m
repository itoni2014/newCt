//
//  DetailChartSubView.m
//  sec
//
//  Created by ias_sec on 2015/12/02.
//
//

#import "DetailChartSubView.h"
#import "DetailChartView.h"
#import "ChartBox.h"
#import "OhlcBean.h"

@implementation DetailChartSubView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    
//    //===========================================================================================//
//    //枠線　テスト用
//    CGContextSetRGBStrokeColor(context, 0/255.0f,0/255.0f,255/255.0f, 1.0);  //BLUE COLOR
//    
////    const CGPoint waku1[] = {
////        CGPointMake( 0, 0 ), CGPointMake( 0, rect.size.height  ) };
////    CGContextStrokeLineSegments(context, waku1, 2);
//    
//    const CGPoint waku_top[] = {
//        CGPointMake( 0, 0 ), CGPointMake( rect.size.width, 0 ) };
//    CGContextStrokeLineSegments(context, waku_top, 2);
//
////    const CGPoint waku3[] = {
////        CGPointMake( rect.size.width, 0 ), CGPointMake( rect.size.width, rect.size.height) };
////    CGContextStrokeLineSegments(context, waku3, 2);
//    
////    const CGPoint waku_bottom[] = {
////        CGPointMake( 0, rect.size.height ), CGPointMake( rect.size.width, rect.size.height ) };
////    CGContextStrokeLineSegments(context, waku_bottom, 2);
//    
//    
//    const CGPoint waku5[] = { CGPointMake(0, self.detail.subChartStartY) , CGPointMake(rect.size.width, self.detail.subChartStartY)};
//    CGContextStrokeLineSegments(context, waku5, 2);
//
//    //===========================================================================================//

    
    
    //Y軸
    CGContextSetRGBStrokeColor(context, COLOR_YAXIS, 1.0);
    CGContextSetLineWidth(context, 1.0);
    const CGPoint yAxis[] = {
        CGPointMake( self.detail.chartWidth /*rect.size.width+1*/, 0),
        CGPointMake( self.detail.chartWidth /*rect.size.width+1*/, rect.size.height ) };
    CGContextStrokeLineSegments(context, yAxis, 2);
    
    //X軸
    const CGPoint xAxis[] = {
        CGPointMake(0, rect.size.height),
        CGPointMake( self.detail.chartWidth /*rect.size.width+1*/, rect.size.height ) };
    CGContextStrokeLineSegments(context, xAxis, 2);
    
//    //上境界線
//    const CGPoint waku[] = {
//        CGPointMake(0, 0),
//        CGPointMake( self.detail.chartWidth /*rect.size.width+1*/, 0) };
//    CGContextStrokeLineSegments(context, waku, 2);
    
    
    
    

    
    //////////////////////////////////////////////////////////////
    
    if([ChartBox sharedInstance].needShowSub_rsi){
        int overSellLine = [[ChartBox sharedInstance].technicalValueDic[@"rsi_day_2"] intValue];
        int overBuyLine = [[ChartBox sharedInstance].technicalValueDic[@"rsi_day_3"] intValue];
        
        //Y軸目盛り（株価）
        CGFloat pointY1 = self.detail.subChartStartY + RATE_IN_RANGE(overBuyLine, 0.f, 100.f) * self.detail.subChartValidHeight; //80
        CGFloat pointY2 = self.detail.subChartStartY + RATE_IN_RANGE(overSellLine, 0.f, 100.f) * self.detail.subChartValidHeight; //20
        CGFloat pointY3 = self.detail.subChartStartY + self.detail.subChartValidHeight * 0.5; //50
        
        [[NSString stringWithFormat:@"%d", overBuyLine] drawAtPoint:CGPointMake( self.detail.chartWidth + 3, pointY1 - 6) withAttributes:FONT_ATTRIBUTE(10)]; //80
        [[NSString stringWithFormat:@"%d", overSellLine] drawAtPoint:CGPointMake( self.detail.chartWidth + 3, pointY2 - 6) withAttributes:FONT_ATTRIBUTE(10)]; //20
        [[NSString stringWithFormat:@"%.0f", (overSellLine + overBuyLine) * 0.5f] drawAtPoint:CGPointMake( self.detail.chartWidth + 3, pointY3 - 6) withAttributes:FONT_ATTRIBUTE(10)]; //50
        
        //Y軸目盛り（線）
        CGContextSetLineWidth(context, LINEWIDTH_DIVIDE);
        
        CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(RSI_OVER_BUY_COLOR[0], RSI_OVER_BUY_COLOR[1], RSI_OVER_BUY_COLOR[2]), 1.0);
        const CGPoint kakakuLine1[] = { CGPointMake(0, pointY1), CGPointMake( self.detail.chartWidth, pointY1) };
        CGContextStrokeLineSegments(context, kakakuLine1, 2);
        const CGPoint kakakuLine2[] = { CGPointMake(0, pointY2), CGPointMake( self.detail.chartWidth, pointY2) };
        CGContextStrokeLineSegments(context, kakakuLine2, 2);
        
        CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(RSI_BASE_COLOR[0], RSI_BASE_COLOR[1], RSI_BASE_COLOR[2]), 1.0);
        const CGPoint kakakuLine3[] = { CGPointMake(0, pointY3), CGPointMake( self.detail.chartWidth, pointY3) };
        CGContextStrokeLineSegments(context, kakakuLine3, 2);
    }
    

    //////////////////////////////////////////////////////////////

    
    
    if([ChartBox sharedInstance].needShowSub_macd){
        //中線
        CGContextSetLineWidth(context, 1.0);
        CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB( 0, 0, 0 ), 1.0);
        
        // 最大・最小
        CGFloat macdMax = 0.f;
        CGFloat macdMin = 0.f;
//        NSInteger startIdx;
//        NSInteger endIdx;
        if( [ChartBox sharedInstance].yAxisFixed ){
//            startIdx = 0;
//            endIdx = [ChartBox sharedInstance].ohlcMutableArray.count;
            macdMax = [ChartBox sharedInstance].macdMaxInAll;
            macdMin = [ChartBox sharedInstance].macdMinInAll;
        }
        else{
            macdMax = [ChartBox sharedInstance].macdMaxInRange;
            macdMin = [ChartBox sharedInstance].macdMinInRange;
        }

        
        CGFloat yPt0 = self.detail.subChartStartY + RATE_IN_RANGE(0.f, macdMin, macdMax) * self.detail.subChartValidHeight;
        const CGPoint line0[] = { CGPointMake(0, yPt0), CGPointMake( self.detail.chartWidth, yPt0 ) };
        CGContextStrokeLineSegments(context, line0, 2);
        [@"0" drawAtPoint:CGPointMake( self.detail.chartWidth + 3, yPt0 - 6) withAttributes:FONT_ATTRIBUTE(10)];

    }
    
    
    if([ChartBox sharedInstance].needShowSub_stochas){
        // 底値ライン
        int overSellLine = [[ChartBox sharedInstance].technicalValueDic[@"stochas_day_3"] intValue];
        int overBuyLine = [[ChartBox sharedInstance].technicalValueDic[@"stochas_day_4"] intValue];

        //Y軸目盛り（株価）
        CGFloat y1 = self.detail.subChartStartY + RATE_IN_RANGE(overBuyLine, 0.f, 100.f) * self.detail.subChartValidHeight;
        CGFloat y2 = self.detail.subChartStartY + RATE_IN_RANGE(overSellLine, 0.f, 100.f) * self.detail.subChartValidHeight;
        [[NSString stringWithFormat:@"%d", overBuyLine] drawAtPoint:CGPointMake(self.detail.chartWidth + 3, y1 - 6) withAttributes:FONT_ATTRIBUTE(10)];
        [[NSString stringWithFormat:@"%d", overSellLine] drawAtPoint:CGPointMake(self.detail.chartWidth + 3, y2 - 6) withAttributes:FONT_ATTRIBUTE(10)];
        
        
        //Y軸目盛り（線）
        CGContextSetLineWidth(context, LINEWIDTH_DIVIDE);
        
        CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(STOCHAS_OVER_BUY_COLOR[0], STOCHAS_OVER_BUY_COLOR[1], STOCHAS_OVER_BUY_COLOR[2]), 1.0);
        const CGPoint kakakuLine1[] = { CGPointMake(0, y1), CGPointMake( self.detail.chartWidth, y1) };
        CGContextStrokeLineSegments(context, kakakuLine1, 2);
        const CGPoint kakakuLine2[] = { CGPointMake(0, y2), CGPointMake( self.detail.chartWidth, y2) };
        CGContextStrokeLineSegments(context, kakakuLine2, 2);

    }
    
    //出来高
    if([ChartBox sharedInstance].needShowSub_volume){
        CGFloat maxVolume = [ChartBox sharedInstance].yAxisFixed ? [ChartBox sharedInstance].maxVolumeInAll : [ChartBox sharedInstance].maxVolumeInRange;
        
        CGContextSetRGBStrokeColor(context, COLOR_DIVIDE_LINE, 1.0); //色の設定
        CGContextSetLineWidth(context, LINEWIDTH_DIVIDE);
        CGFloat yPos = self.detail.subChartStartY + RATE_WITH_NUMBER([ChartBox getTheClosestVolume: maxVolume], maxVolume) * self.detail.subChartValidHeight;
        const CGPoint line[] = { CGPointMake(0, yPos), CGPointMake( self.detail.chartWidth, yPos) };
        CGContextStrokeLineSegments(context, line, 2);
        
        NSString *strVolume = [NSString stringWithFormat:@"%.0f", [ChartBox getTheClosestVolume: maxVolume] / 1000 ];
        CGPoint pt = CGPointMake(self.detail.chartWidth + 3, yPos - 5);
        [strVolume drawAtPoint:pt withAttributes: FONT_ATTRIBUTE(10)];
        
//        NSString *volumeLabel = @"出来高(×1000)";
//        [volumeLabel drawAtPoint:CGPointMake(22, 0) withAttributes:FONT_ATTRIBUTE(10)];

    }
    
    
}


@end
