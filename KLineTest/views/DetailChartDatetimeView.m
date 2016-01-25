

#import "DetailChartDatetimeView.h"
#import "DetailChartView.h"
#import "ChartBox.h"
#import "OhlcBean.h"
//#import "ContentsManagerViewController.h"

@implementation DetailChartDatetimeView


- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    //===========================================================================================//
    //枠線　テスト用
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBStrokeColor(context, 0/255.0f,0/255.0f,0/255.0f, 1.0);//色を黒に設定

//    const CGPoint waku_top[] = {
//        CGPointMake( 0, 0 ), CGPointMake( rect.size.width, 0 ) };
//    CGContextStrokeLineSegments(context, waku_top, 2);

//    CGContextSetRGBStrokeColor(context, 255/255.0f,0/255.0f,0/255.0f, 1.0);
//
//    const CGPoint waku_left[] = {
//        CGPointMake( 0, 0 ), CGPointMake( 0, rect.size.height  ) };
//    CGContextStrokeLineSegments(context, waku_left, 2);
//    
//
//
//    const CGPoint waku_right[] = {
//        CGPointMake( rect.size.width, 0 ), CGPointMake( rect.size.width, rect.size.height) };
//    CGContextStrokeLineSegments(context, waku_right, 2);
    
//    const CGPoint waku_bottom[] = {
//        CGPointMake( 0, rect.size.height ), CGPointMake( rect.size.width, rect.size.height ) };
//    CGContextStrokeLineSegments(context, waku_bottom, 2);


    //===========================================================================================//
    
    
    
    [[ChartBox sharedInstance].ymdMutableArray removeAllObjects];


    //開始座標
    CGFloat startX = [[ChartBox sharedInstance]getValidLeftBorder:0];// [ChartBox sharedInstance].candleStickBodyWidth / 2;
    
    for(NSInteger i = 0; i < [ChartBox sharedInstance].ohlcMutableArray.count; i++){
        OhlcBean *bean = [[ChartBox sharedInstance].ohlcMutableArray objectAtIndex:i];
        
        NSString *yyyymm = bean.fourValuesDate.length == 10 ? [bean.fourValuesDate substringWithRange: NSMakeRange(5, 5)] :
        [NSString stringWithFormat: @"%@/%@", [bean.fourValuesDate substringWithRange: NSMakeRange(0, 4)], [bean.fourValuesDate substringWithRange: NSMakeRange(4, 2)] ];
        NSString *mm = bean.fourValuesDate.length == 10 ? [bean.fourValuesDate substringWithRange: NSMakeRange(5, 2)] :
        [bean.fourValuesDate substringWithRange: NSMakeRange(4, 2)];
        NSString *mmdd = bean.fourValuesDate.length == 10 ? [bean.fourValuesDate substringWithRange: NSMakeRange(2, 8)] :
        [NSString stringWithFormat:@"%@/%@",[bean.fourValuesDate substringWithRange:NSMakeRange(4, 2) ], [bean.fourValuesDate substringFromIndex: 6]  ];
        NSString *hhmm = bean.fourValuesTime;
        if(hhmm.length == 6){
            hhmm = [NSString stringWithFormat:@"%@:%@", [bean.fourValuesTime substringToIndex: 2],[bean.fourValuesTime substringWithRange:NSMakeRange(2, 2)]];
        }

        
        
        const CGPoint shortline[] = { CGPointMake(startX, 0 ), CGPointMake(startX, 3 ) };
        CGPoint datePoint = CGPointMake(startX - 15, rect.size.height - 8);

//        //1分足
//        if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES1]){
//            
//            if(bean.fourValuesTime.length >= 4 && [[bean.fourValuesTime substringWithRange:NSMakeRange(3, 1)] isEqualToString:@"0"] ){
//
//                CGContextStrokeLineSegments(context, shortline, 2);
//                [hhmm drawAtPoint:datePoint withAttributes: FONT_ATTRIBUTE(7)];
//            }
//        }
//        //10分足
//        if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES10] ) {
//            
//            if(bean.fourValuesTime.length >= 4 && [[bean.fourValuesTime substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"00"] && ![[bean.fourValuesTime substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"15"]){
//                
//                CGContextStrokeLineSegments(context, shortline, 2);
//                [hhmm drawAtPoint:datePoint withAttributes: FONT_ATTRIBUTE(7)];
//            }
//        }
//        //60分足
//        if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_TIME] && i % 10 == 0 ) {
//            
//            CGContextStrokeLineSegments(context, shortline, 2);
//            [hhmm drawAtPoint:datePoint withAttributes: FONT_ATTRIBUTE(7)];
//        }
//        
//        //日足
//        if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_DAY] && [[ChartBox sharedInstance] isMonthHead: bean.fourValuesDate] ){
//
////            CGFloat pointX = i * ([ChartBox sharedInstance].candleStickBodyWidth + [ChartBox sharedInstance].candleStickInterval) + [ChartBox sharedInstance].candleStickBodyWidth / 2;
//            CGContextStrokeLineSegments(context, shortline, 2);
//            [yyyymm drawAtPoint: datePoint withAttributes: FONT_ATTRIBUTE(7)];
//            
//        }
//        
//        //週足
//        if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_WEEK] && i % 15 == 0 ){
//            CGContextStrokeLineSegments(context, shortline, 2);
//            [mmdd drawAtPoint: datePoint withAttributes: FONT_ATTRIBUTE(7)];
//        }
//
//        //月足
//        if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MONTH] && [@"01" isEqualToString: mm] ){
//            CGContextStrokeLineSegments(context, shortline, 2);
//            [yyyymm drawAtPoint:datePoint withAttributes: FONT_ATTRIBUTE(7)];
//        }
        
        
        startX += [[ChartBox sharedInstance]getStickUnitWidth];
    }

}


@end
