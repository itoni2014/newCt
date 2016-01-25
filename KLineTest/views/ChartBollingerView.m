

#import "ChartBollingerView.h"
#import "ChartBox.h"
#import "DetailChartView.h"

@implementation ChartBollingerView


- (void)drawRect:(CGRect)rect {
    if([ChartBox sharedInstance].bollingerInfoArray.count == 0){
        return;
    }
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    CGFloat minPrice = [ChartBox sharedInstance].yAxisFixed ? [ChartBox sharedInstance].minPriceInAll : [ChartBox sharedInstance].minPriceInRange;
    CGFloat maxPrice = [ChartBox sharedInstance].yAxisFixed ? [ChartBox sharedInstance].maxPriceInAll : [ChartBox sharedInstance].maxPriceInRange;

    CGFloat startX = [ChartBox sharedInstance].candleStickBodyWidth / 2;
    CGFloat startY = Y_BEGIN_POINT(rect.size.height);
    CGFloat mainChartHeight = VALID_HEIGHT_MAIN(rect.size.height);

    CGContextSetLineWidth(context, 1);

    //移動平均
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(0, 0, 0),  1.0);
    startX = [[ChartBox sharedInstance]getValidLeftBorder:0];

    BOOL isBeginPoint = YES;
    for(NSMutableArray *mutableArray in [ChartBox sharedInstance].bollingerInfoArray){
        if(mutableArray == nil || mutableArray.count == 0){
            
        }
        else{
            NSDecimalNumber *bollinger1 = mutableArray[0];
            if( bollinger1 == nil || [bollinger1 isEqual:[NSNull null]] ){
            }
            else{
                CGFloat ptY1 = startY + RATE_IN_RANGE(bollinger1.floatValue, minPrice, maxPrice) * mainChartHeight;
                if(isBeginPoint){
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
        
        startX += [[ChartBox sharedInstance]getStickUnitWidth];// .candleStickBodyWidth + [ChartBox sharedInstance].candleStickInterval;
    }
    
    
    //TOP1
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(0, 0, 255), 1.0);
    startX = [[ChartBox sharedInstance]getValidLeftBorder:0];
    
    isBeginPoint = YES;
    for(NSMutableArray *mutableArray in [ChartBox sharedInstance].bollingerInfoArray){
        if(mutableArray == nil || mutableArray.count == 0){
        }
        else{
            NSDecimalNumber *bollinger1 = mutableArray[1];
            if( bollinger1 == nil || [bollinger1 isEqual:[NSNull null]] ){
            }
            else{
                CGFloat ptY1 = startY + RATE_IN_RANGE( bollinger1.floatValue, minPrice, maxPrice) * mainChartHeight;
                if(isBeginPoint){
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
    
    
    //LOW1
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(255, 0, 255), 1.0);
    startX = [[ChartBox sharedInstance]getValidLeftBorder:0];
    
    isBeginPoint = YES;
    for(NSMutableArray *mutableArray in [ChartBox sharedInstance].bollingerInfoArray){
        if(mutableArray == nil || mutableArray.count == 0){
        }
        else{
            NSDecimalNumber *bollinger1 = mutableArray[2];
            if( bollinger1 == nil || [bollinger1 isEqual:[NSNull null]] ){
            }
            else{
                CGFloat ptY1 = startY + RATE_IN_RANGE( bollinger1.floatValue, minPrice, maxPrice) * mainChartHeight;
                if(isBeginPoint){
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
    
    
    //TOP2
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(0, 255, 0), 1.0);
    startX = [[ChartBox sharedInstance]getValidLeftBorder:0];
    
    isBeginPoint = YES;
    for(NSMutableArray *mutableArray in [ChartBox sharedInstance].bollingerInfoArray){
        if(mutableArray == nil || mutableArray.count == 0){
        }
        else{
            NSDecimalNumber *bollinger1 = mutableArray[3];
            if( bollinger1 == nil || [bollinger1 isEqual:[NSNull null]] ){
            }
            else{
                CGFloat ptY1 = startY + RATE_IN_RANGE( bollinger1.floatValue, minPrice, maxPrice) * mainChartHeight;
                if(isBeginPoint){
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
    
    
    //LOW2
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(255, 0, 0), 1.0);
    startX = [[ChartBox sharedInstance]getValidLeftBorder:0];
    
    isBeginPoint = YES;
    for(NSMutableArray *mutableArray in [ChartBox sharedInstance].bollingerInfoArray){
        if(mutableArray == nil || mutableArray.count == 0){
        }
        else{
            NSDecimalNumber *bollinger1 = mutableArray[4];
            if( bollinger1 == nil || [bollinger1 isEqual:[NSNull null]] ){
            }
            else{
                CGFloat ptY1 = startY + RATE_IN_RANGE( bollinger1.floatValue, minPrice, maxPrice) * mainChartHeight;
                if(isBeginPoint){
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
    
    
}

@end
