//
//  DetailChartMovAvgView.m
//  sec
//
//  Created by ias_sec on 2015/12/02.
//
//

#import "ChartMovAvgView.h"
#import "ChartBox.h"
#import "OhlcBean.h"
#import "DetailChartView.h"

@implementation ChartMovAvgView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGFloat minPrice = [ChartBox sharedInstance].yAxisFixed ? [ChartBox sharedInstance].minPriceInAll : [ChartBox sharedInstance].minPriceInRange;
    CGFloat maxPrice = [ChartBox sharedInstance].yAxisFixed ? [ChartBox sharedInstance].maxPriceInAll : [ChartBox sharedInstance].maxPriceInRange;

    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1);
    
    
    //短期
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(MOVAVG_SHORT_COLOR[0], MOVAVG_SHORT_COLOR[1], MOVAVG_SHORT_COLOR[2]), 1.0);
    
    CGFloat startX = [[ChartBox sharedInstance]getValidLeftBorder:0]; //.candleStickBodyWidth / 2;
    BOOL firstPoint = YES;
    for(NSDecimalNumber *number in [ChartBox sharedInstance].maShortArray){
        if(![number isEqual:[NSNull null]]){

            CGFloat ptY = Y_BEGIN_POINT(rect.size.height) + RATE_IN_RANGE(number.floatValue, minPrice, maxPrice) * VALID_HEIGHT_MAIN(rect.size.height);
            if(firstPoint){
                CGContextMoveToPoint(context, startX, ptY);
                firstPoint = NO;
            }
            else{
                CGContextAddLineToPoint(context, startX, ptY);
                CGContextStrokePath(context);
                CGContextMoveToPoint(context, startX, ptY);
            }
        }

        startX += [[ChartBox sharedInstance]getStickUnitWidth];
    }
    
    //中期
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(MOVAVG_MEDIUM_COLOR[0],MOVAVG_MEDIUM_COLOR[1],MOVAVG_MEDIUM_COLOR[2]), 1.0);
    startX = [[ChartBox sharedInstance]getValidLeftBorder:0];//[ChartBox sharedInstance].candleStickBodyWidth / 2;
    firstPoint = YES;
    for(NSDecimalNumber *number in [ChartBox sharedInstance].maMediumArray){
        if(![number isEqual:[NSNull null]]) {
            CGFloat ptY = Y_BEGIN_POINT(rect.size.height) + RATE_IN_RANGE(number.floatValue, minPrice, maxPrice) * VALID_HEIGHT_MAIN(rect.size.height);
            if(firstPoint){
                CGContextMoveToPoint(context, startX, ptY);
                firstPoint = NO;
            }
            else{
                CGContextAddLineToPoint(context, startX, ptY);
                CGContextStrokePath(context);
                CGContextMoveToPoint(context, startX, ptY);
            }
        }
        
        startX += [[ChartBox sharedInstance]getStickUnitWidth];
    }
    
    //長期
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(MOVAVG_LONG_COLOR[0], MOVAVG_LONG_COLOR[1], MOVAVG_LONG_COLOR[2]), 1.0 );
    startX = [[ChartBox sharedInstance]getValidLeftBorder:0];
    firstPoint = YES;
    for(NSDecimalNumber *number in [ChartBox sharedInstance].maLongArray){

        if(![number isEqual:[NSNull null]]){
            CGFloat ptY = Y_BEGIN_POINT(rect.size.height) + RATE_IN_RANGE(number.floatValue, minPrice, maxPrice) * VALID_HEIGHT_MAIN(rect.size.height);
            
            if(firstPoint){
                CGContextMoveToPoint(context, startX, ptY);
                firstPoint = NO;
            }
            else{
                CGContextAddLineToPoint(context, startX, ptY);
                CGContextStrokePath(context);
                CGContextMoveToPoint(context, startX, ptY);
            }
        }
        
        startX += [[ChartBox sharedInstance]getStickUnitWidth];
    }
    
    
}


@end
