

#import "ChartIchimokuView.h"
#import "OhlcBean.h"
#import "ChartBox.h"
#import "DetailChartView.h"

@implementation ChartIchimokuView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    if([ChartBox sharedInstance].ichimokuInfoArray.count == 0){
        return;
    }

    
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGFloat minPrice = [ChartBox sharedInstance].yAxisFixed ? [ChartBox sharedInstance].minPriceInAll : [ChartBox sharedInstance].minPriceInRange;
    CGFloat maxPrice = [ChartBox sharedInstance].yAxisFixed ? [ChartBox sharedInstance].maxPriceInAll : [ChartBox sharedInstance].maxPriceInRange;


    CGContextSetLineWidth(context, 1);

    
    // 転換線
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(ITIMOKU_CONVERSION_COLOR[0], ITIMOKU_CONVERSION_COLOR[1], ITIMOKU_CONVERSION_COLOR[2]), 1.0);
    
    CGFloat startX = [ChartBox sharedInstance].candleStickBodyWidth / 2;
    

    BOOL isBeginPoint = YES;
    startX = [[ChartBox sharedInstance]getValidLeftBorder:0];
    for(NSMutableArray *mutableArray in [ChartBox sharedInstance].ichimokuInfoArray){
        if(mutableArray == nil || mutableArray.count == 0){
            
        }
        else{
            NSDecimalNumber *itimoku = mutableArray[0];
            if(itimoku == nil || [itimoku isEqual: [NSNull null]] ){
            }
            else{
                CGFloat ptY1 = Y_BEGIN_POINT(rect.size.height) + RATE_IN_RANGE(itimoku.floatValue, minPrice, maxPrice) * VALID_HEIGHT_MAIN(rect.size.height);
                
                if( isBeginPoint /*startX == [ChartBox sharedInstance].candleStickBodyWidth / 2*/){
                    CGContextMoveToPoint(context, startX,  ptY1);
                    isBeginPoint = NO;
                }
                else{
                    CGContextAddLineToPoint(context, startX, ptY1);
                    CGContextStrokePath(context);
                    CGContextMoveToPoint(context, startX, ptY1);
                }
            }
        }
        
        startX += [[ChartBox sharedInstance]getStickUnitWidth];
    }
    
    
    // 基準線
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(ITIMOKU_BASE_COLOR[0], ITIMOKU_BASE_COLOR[1], ITIMOKU_BASE_COLOR[2]) , 1.0);
    startX = [[ChartBox sharedInstance]getValidLeftBorder:0];
    isBeginPoint = YES;
    for(NSMutableArray *mutableArray in [ChartBox sharedInstance].ichimokuInfoArray){
        
        if(mutableArray == nil || mutableArray.count == 0){
            
        }
        else{
            NSDecimalNumber *itimoku = mutableArray[1];
            if(itimoku == nil || [itimoku isEqual: [NSNull null]] ){
            }
            else{
                CGFloat ptY1 = Y_BEGIN_POINT(rect.size.height) + RATE_IN_RANGE(itimoku.floatValue, minPrice, maxPrice) * VALID_HEIGHT_MAIN(rect.size.height);

                if( isBeginPoint /*startX == [ChartBox sharedInstance].candleStickBodyWidth / 2*/){
                    CGContextMoveToPoint(context, startX, ptY1);
                    isBeginPoint = NO;
                }
                else{
                    CGContextAddLineToPoint(context, startX,  ptY1);
                    CGContextStrokePath(context);
                    CGContextMoveToPoint(context, startX,  ptY1);
                }
            }
        }
        
        startX += [[ChartBox sharedInstance]getStickUnitWidth];
    }
    
    
    // 遅行線
//    int laggingCnt = 0;
//    int laggingCnt2 = 0;
//    int laggingCnt3 = 0;
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(ITIMOKU_LAGGING_COLOR[0], ITIMOKU_LAGGING_COLOR[1], ITIMOKU_LAGGING_COLOR[2]), 1.0);
    startX = [[ChartBox sharedInstance]getValidLeftBorder:0];
    isBeginPoint = YES;
    for(NSMutableArray *mutableArray in [ChartBox sharedInstance].ichimokuInfoArray){
        if(mutableArray == nil || mutableArray.count != 5){
            
        }
        else{
            NSDecimalNumber *itimoku = mutableArray[2];
            if(itimoku != nil && ![itimoku isEqual: [NSNull null]] ){
                CGFloat ptY1 = Y_BEGIN_POINT(rect.size.height) + RATE_IN_RANGE(itimoku.floatValue, minPrice, maxPrice) * VALID_HEIGHT_MAIN(rect.size.height);

                if( isBeginPoint /*startX == [ChartBox sharedInstance].candleStickBodyWidth / 2*/){
                    CGContextMoveToPoint(context, startX, ptY1);
                    isBeginPoint = NO;
                }

                else{
                    CGContextAddLineToPoint(context, startX, ptY1);
                    CGContextStrokePath(context);
                    CGContextMoveToPoint(context, startX, ptY1);
                    
//                    laggingCnt3++;
                }
                
//                laggingCnt++;
            }
        }
        
        startX += [[ChartBox sharedInstance]getStickUnitWidth];
    }
    
    
    // 先行スパン1
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(ITIMOKU_LEADING_SPAN1_COLOR[0], ITIMOKU_LEADING_SPAN1_COLOR[1], ITIMOKU_LEADING_SPAN1_COLOR[2]), 1.0);
    startX = [[ChartBox sharedInstance]getValidLeftBorder:0];

    isBeginPoint = YES;
    for(NSMutableArray *mutableArray in [ChartBox sharedInstance].ichimokuInfoArray){
        if(mutableArray == nil || mutableArray.count == 0){
            
        }
        else{
            NSDecimalNumber *itimoku = mutableArray[3];
            if(itimoku == nil || [itimoku isEqual: [NSNull null]] ){
            }
            else{
                CGFloat ptY1 = Y_BEGIN_POINT(rect.size.height) + RATE_IN_RANGE(itimoku.floatValue, minPrice, maxPrice) * VALID_HEIGHT_MAIN(rect.size.height);

                if( isBeginPoint /*startX == [ChartBox sharedInstance].candleStickBodyWidth / 2*/){
                    CGContextMoveToPoint(context, startX, ptY1);
                    isBeginPoint = NO;
                }

                else{
                    CGContextAddLineToPoint(context, startX, ptY1);
                    CGContextStrokePath(context);
                    CGContextMoveToPoint(context, startX, ptY1);
                    
                }
            }
        }
        
        startX += [[ChartBox sharedInstance]getStickUnitWidth];
    }
    
    
    // 先行スパン2
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB( ITIMOKU_LEADING_SPAN2_COLOR[0], ITIMOKU_LEADING_SPAN2_COLOR[1], ITIMOKU_LEADING_SPAN2_COLOR[2]), 1.0);
    startX = [[ChartBox sharedInstance]getValidLeftBorder:0];

    isBeginPoint = YES;
    for(NSMutableArray *mutableArray in [ChartBox sharedInstance].ichimokuInfoArray){
        if(mutableArray == nil || mutableArray.count == 0){
            
        }
        else{
            NSDecimalNumber *itimoku = mutableArray[4];
            if(itimoku == nil || [itimoku isEqual: [NSNull null]] ){
            }
            else{
                CGFloat ptY1 = Y_BEGIN_POINT(rect.size.height) + RATE_IN_RANGE(itimoku.floatValue, minPrice, maxPrice) * VALID_HEIGHT_MAIN(rect.size.height);

                if( isBeginPoint /*startX == [ChartBox sharedInstance].candleStickBodyWidth / 2*/){
                    CGContextMoveToPoint(context, startX, ptY1);
                    isBeginPoint = NO;
                }

                else{
                    CGContextAddLineToPoint(context, startX, ptY1);
                    CGContextStrokePath(context);
                    CGContextMoveToPoint(context, startX,  ptY1);
                    
                }
            }
        }
        
        startX += [[ChartBox sharedInstance]getStickUnitWidth];
    }
    
    
    
    // 雲
    CGContextSetLineWidth(context, [ChartBox sharedInstance].candleStickBodyWidth + [ChartBox sharedInstance].candleStickInterval);
    startX = [[ChartBox sharedInstance]getValidLeftBorder:0];
    for(NSMutableArray *mutableArray in [ChartBox sharedInstance].ichimokuInfoArray){
        if(mutableArray == nil || mutableArray.count == 0){
            
        }
        else{
            NSDecimalNumber *span1 = mutableArray[3];
            NSDecimalNumber *span2 = mutableArray[4];
            if(span1 == nil || [span1 isEqual: [NSNull null]] || span2 == nil || [span2 isEqual: [NSNull null]] ){
            }
            else{
                CGFloat ptYSpan1 = Y_BEGIN_POINT(rect.size.height) + RATE_IN_RANGE(span1.floatValue, minPrice, maxPrice) * VALID_HEIGHT_MAIN(rect.size.height);
                CGFloat ptYSpan2 = Y_BEGIN_POINT(rect.size.height) + RATE_IN_RANGE(span2.floatValue, minPrice, maxPrice) * VALID_HEIGHT_MAIN(rect.size.height);
                
                ptYSpan1 < ptYSpan2 ? CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(ITIMOKU_CLOUD1_COLOR[0], ITIMOKU_CLOUD1_COLOR[1], ITIMOKU_CLOUD1_COLOR[2]), 0.5) : CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB( ITIMOKU_CLOUD2_COLOR[0], ITIMOKU_CLOUD2_COLOR[1], ITIMOKU_CLOUD2_COLOR[2]), 0.5);
                
                const CGPoint cloud[] = { CGPointMake(startX, ptYSpan1), CGPointMake(startX, ptYSpan2) };
                CGContextStrokeLineSegments(context, cloud, 2);
                
            }
        }
        
        startX += [[ChartBox sharedInstance]getStickUnitWidth];
    }
    

}


@end
