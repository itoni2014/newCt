//
//  ChartView.m
//  livestarS2
//
//  Created by ias_sec on 2015/11/11.
//  Copyright © 2015年 ias_sec. All rights reserved.
//

#import "ChartView.h"
#import "ChartBox.h"
#import "OhlcBean.h"
//#import "DropDownListView.h"
#import "FourPricesView.h"
#import "ChartNamesView.h"
#import "SubChartNamesView.h"
//#import "TechnicalSetting.h"




/** チャートのX軸開始描画位置 */
#define CHART_X_OFFSET 16.f//20.0f
/** テクニカル指標文字のサイズ */
#define FONTSIZE_TECH_LABEL 10.f

@interface ChartView()<UITableViewDataSource>
{
    /* チャートの幅 */
    CGFloat chartWidth;
    /* メインチャートの高さ */
    CGFloat mainChartHeight;
    /* メインチャートとサブチャートの余白 */
    CGFloat chartInterval;
    /* サブチャートの高さ */
    CGFloat subChartHeight;
    /* チャートの高さ */
    CGFloat chartHeight;
    /* 描画用チャートの高さ */
    CGFloat takasa;
    /* ローソクステックの幅 */
    CGFloat candleStickBodyWidth;
    /* ローソクステックの間隔 */
    CGFloat candleStickInterval;
    /* チャートのX軸開始描画位置 */
    CGFloat startX;
    /* チャートのY軸開始描画位置 */
    CGFloat startY;
    /* メインテクニカル指標のラベルY位置 */
    CGFloat tech1LabelStringPositionY;
    /* サブテクニカル指標のラベルY位置 */
    CGFloat tech2LabelStringPositionY;

    /* 足種、メインテクニカル、サブテクニカルボタンの高さ */
    CGFloat btnHeight;
    
    BOOL hideSubchart;
    
    /* 四本値 */
    FourPricesView *fourPricesView;
    /* X軸カーソルビュー */
    UIView *cursorView;

    ChartNamesView *chartNamesView;
    UIView *ichimokuNameView;
    UIView *bollingerNameView;
    UIView *rsiNameView;
    UIView *macdNameView;
    UIView *stochasNameView;
    UIView *volumeNameView;

    UIButton *tech1SelectButton;
    UIButton *tech2SelectButton;
    
    UITableView *ashiTableView;
    UITableView *tech1TableView;
    UITableView *tech2TableView;

//    ChartMemoryManager *chartMemoryManager;

    NSInteger leftBorderPosition;
    
    UIActivityIndicatorView *activityIndicatorView;
}



@end

@implementation ChartView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        
        self.backgroundColor = [UIColor whiteColor];

        startX = CHART_X_OFFSET;
        startY = frame.size.height/7.0;

        chartWidth = frame.size.width * 0.84f;
        mainChartHeight = frame.size.height * 0.5f;
        chartInterval = frame.size.height * 0.08f;
        subChartHeight = frame.size.height * 0.1f;
        chartHeight = mainChartHeight + chartInterval + subChartHeight - startY/2;
        candleStickBodyWidth = chartWidth / CANDLE_STICK_COUNT * 0.7f;
        candleStickInterval = chartWidth / CANDLE_STICK_COUNT * 0.3f;
        [ChartBox sharedInstance].candleStickBodyWidth = candleStickBodyWidth;
        [ChartBox sharedInstance].candleStickInterval = candleStickInterval;
        
        btnHeight = self.frame.size.height /18;
        

        fourPricesView = [[FourPricesView alloc]initWithFrame:CGRectMake(5, 0, chartWidth, frame.size.height / 14.0) orientation:YES];
        [self addSubview: fourPricesView];

        //回転ボタン
        UIButton *changeOrientationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [changeOrientationButton setBackgroundImage:[UIImage imageNamed:@"button_screenlandscape.png"] forState:UIControlStateNormal];
        changeOrientationButton.frame = CGRectMake(frame.size.width - 40, fourPricesView.frame.size.height/2 - 35/2, 35, 35);
        [changeOrientationButton addTarget:self action:@selector(changeOrientationButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:changeOrientationButton];

        
        tech1LabelStringPositionY = fourPricesView.frame.origin.y + fourPricesView.frame.size.height + 10;
        tech2LabelStringPositionY = startY + mainChartHeight + chartInterval - 15;

        
        chartNamesView = [[ChartNamesView alloc]initWithFrame:CGRectMake(startX, tech1LabelStringPositionY, chartWidth, 20) orientation:YES];
        [self addSubview:chartNamesView];

//        subChartNamesView = [[SubChartNamesView alloc] initWithFrame:CGRectMake(startX, tech2LabelStringPositionY, chartWidth, 20) orientation:YES];
//        [self addSubview:subChartNamesView];
        
        [self initBollingerNameView];
        [self initIchimokuNameView];
        [self initRsiNameView];
        [self initMacdNameView];
        [self initStochasNameView];
        [self initVolumeNameView];
        


        [self initCursorView];

        
        [self initChartSelect];

        [self updateButtonTitles];

//        int viewHeight = 30*SIZE;
//        UIView *viewMenu = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-viewHeight, frame.size.width, viewHeight)];
//        [self addSubview:viewMenu];
//        [self menuShow:viewMenu];
        

        activityIndicatorView = [ [UIActivityIndicatorView alloc] initWithFrame:CGRectMake(frame.size.width/2, 220.0,30.0,30.0)];
        activityIndicatorView.center = self.center;
        activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        activityIndicatorView.hidesWhenStopped = NO;
        [self addSubview:activityIndicatorView];
        [activityIndicatorView startAnimating];

        
        
    }
    
    return self;
}


- (void)drawRect:(CGRect)rect {
    // コンテキストを取得
    CGContextRef context = UIGraphicsGetCurrentContext();

    if(![ChartBox sharedInstance].needShowSub_rsi && ![ChartBox sharedInstance].needShowSub_macd && ![ChartBox sharedInstance].needShowSub_stochas && ![ChartBox sharedInstance].needShowSub_volume) {

        hideSubchart = YES;
        takasa = chartHeight;
    }
    else{
        hideSubchart = NO;
        takasa = mainChartHeight;
    }

    
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(0, 0, 0), 1.0);

    //Y軸
    CGContextSetLineWidth(context, LINEWIDTH_WAKU);
    const CGPoint yAxis[] = {
        CGPointMake( CHART_X_OFFSET + chartWidth, tech1LabelStringPositionY),
        CGPointMake( CHART_X_OFFSET + chartWidth, startY + mainChartHeight + chartInterval + subChartHeight) };
    CGContextStrokeLineSegments(context, yAxis, 2);
//    //左枠線
//    const CGPoint leftWaku[] = {
//        CGPointMake(startX, startY), CGPointMake(startX, startY + mainChartHeight + chartInterval + subChartHeight) };
//    CGContextStrokeLineSegments(context, leftWaku, 2);

    //MainChart下枠
//    const CGPoint horizLine[] = { CGPointMake(startX, startY + mainChartHeight), CGPointMake(startX + chartWidth, startY + mainChartHeight) };
//    CGContextStrokeLineSegments(context, horizLine, 2);

    //MainChart SubChart間隔線
//    CGContextSetLineWidth(context, 1.0);
    if(hideSubchart == NO){
        const CGPoint divideLine[] = {
        CGPointMake(CHART_X_OFFSET, startY + mainChartHeight + chartInterval/2 ),
        CGPointMake(CHART_X_OFFSET + chartWidth, startY + mainChartHeight + chartInterval/2 ) };
        CGContextStrokeLineSegments(context, divideLine, 2);
    }


    //////////////////////////////////////////////////////////////////////////////////////////////
//    CGContextSetLineWidth(context, 0.5);

//    //MainChartのCeiling線
//    const CGPoint ceilingLine[] = {
//        CGPointMake( startX , startY), CGPointMake( startX + chartWidth, startY) };
//    CGContextStrokeLineSegments(context, ceilingLine, 2);

//    //SubChartのCeiling線
//    const CGPoint subChartCeilingLine[] = { CGPointMake(startX,              startY + mainChartHeight + chartInterval),
//                                  CGPointMake(startX + chartWidth, startY + mainChartHeight + chartInterval) };
//    CGContextStrokeLineSegments(context, subChartCeilingLine, 2);
    
//    const CGPoint bottomLine[] = {
//        CGPointMake(startX,              startY + mainChartHeight + chartInterval + subChartHeight ),
//        CGPointMake(startX + chartWidth, startY + mainChartHeight + chartInterval + subChartHeight) };
//    CGContextStrokeLineSegments(context, bottomLine, 2);
    //////////////////////////////////////////////////////////////////////////////////////////////
    
    if([ChartBox sharedInstance].ohlcArray_in_chart.count == 0){
        //X軸
        CGContextSetLineWidth(context, 1.0);
        CGContextSetRGBStrokeColor(context, COLOR_YAXIS, 1.0);
        const CGPoint xAxis[] = {
            CGPointMake(CHART_X_OFFSET,              startY + mainChartHeight + chartInterval + subChartHeight),
            CGPointMake(CHART_X_OFFSET + chartWidth, startY + mainChartHeight + chartInterval + subChartHeight) };
        CGContextStrokeLineSegments(context, xAxis, 2);

        return;
    }

    //Y軸目盛り
    NSArray *priceArray = [ChartBox getPricesByHighPrice:[ChartBox sharedInstance].maxPrice lowPrice:[ChartBox sharedInstance].minPrice];
    //    CGContextSetShouldAntialias(context, NO);
    CGContextSetRGBStrokeColor(context, COLOR_DIVIDE_LINE, 1.0);
    CGContextSetLineWidth(context, LINEWIDTH_DIVIDE);

    for(NSNumber *price in priceArray){
        if(price.floatValue < [ChartBox sharedInstance].minPrice || price.floatValue > [ChartBox sharedInstance].maxPrice)
            continue;
        
        //線
        CGFloat yPos = startY + RATE_IN_RANGE(price.floatValue, [ChartBox sharedInstance].minPrice, [ChartBox sharedInstance].maxPrice) * takasa;
        const CGPoint kakakuLine[] = { CGPointMake(CHART_X_OFFSET, yPos), CGPointMake(CHART_X_OFFSET + chartWidth, yPos) };
        CGContextStrokeLineSegments(context, kakakuLine, 2);
        
        //株価
        [price.stringValue drawAtPoint:CGPointMake(CHART_X_OFFSET + chartWidth + 3, yPos - 6) withAttributes:FONT_ATTRIBUTE(10)];
    }

    
    [[ChartBox sharedInstance].ymdMutableArray removeAllObjects];
    
    leftBorderPosition = (CANDLE_STICK_COUNT - [ChartBox sharedInstance].ohlcArray_in_chart.count) * (candleStickBodyWidth + candleStickInterval);

    //ローソク、日付
    startX = CHART_X_OFFSET + leftBorderPosition + candleStickBodyWidth / 2;
    NSInteger idx = 0;
    for(OhlcBean *bean in [ChartBox sharedInstance].ohlcArray_in_chart) {
        bean.openPrice.floatValue <= bean.closePrice.floatValue ? CGContextSetRGBStrokeColor(context, COLOR_CANDLESTICK_RISE, 1.0) :CGContextSetRGBStrokeColor(context, COLOR_CANDLESTICK_FALL, 1.0);
        
        //ローソク足
        CGContextSetLineWidth(context, candleStickBodyWidth/3.33);
        const CGPoint candleStickShadow[] = {
            CGPointMake(startX, startY + RATE_IN_RANGE(bean.highPrice.floatValue, [ChartBox sharedInstance].minPrice,[ChartBox sharedInstance].maxPrice) * takasa),
            CGPointMake(startX, startY + RATE_IN_RANGE(bean.lowPrice.floatValue, [ChartBox sharedInstance].minPrice,[ChartBox sharedInstance].maxPrice) * takasa)};
        CGContextStrokeLineSegments(context, candleStickShadow, 2);
        
        CGContextSetLineWidth(context, candleStickBodyWidth);
        const CGPoint candleStickBody[] = {
            CGPointMake(startX, startY + RATE_IN_RANGE(bean.openPrice.floatValue, [ChartBox sharedInstance].minPrice,[ChartBox sharedInstance].maxPrice) * takasa),
            CGPointMake(startX, startY + RATE_IN_RANGE(bean.closePrice.floatValue, [ChartBox sharedInstance].minPrice,[ChartBox sharedInstance].maxPrice) * takasa)};
        CGContextStrokeLineSegments(context, candleStickBody, 2);
        
        //日付・時刻
        const CGPoint dateMark[] = {
            CGPointMake(startX, startY + mainChartHeight + chartInterval + subChartHeight),
            CGPointMake(startX, startY + mainChartHeight + chartInterval + subChartHeight + 3) };
        CGContextSetRGBStrokeColor(context, COLOR_YAXIS, 1.0);
        CGContextSetLineWidth(context, 1);


        NSString *yyyymm = bean.fourValuesDate.length == 10 ? [bean.fourValuesDate substringWithRange: NSMakeRange(5, 5)] :
        [NSString stringWithFormat: @"%@/%@", [bean.fourValuesDate substringWithRange: NSMakeRange(0, 4)], [bean.fourValuesDate substringWithRange: NSMakeRange(4, 2)] ];
        NSString *mm = bean.fourValuesDate.length == 10 ? [bean.fourValuesDate substringWithRange: NSMakeRange(5, 2)] :
         [bean.fourValuesDate substringWithRange: NSMakeRange(4, 2)];
        NSString *mmdd = bean.fourValuesDate.length == 10 ? [bean.fourValuesDate substringWithRange: NSMakeRange(2, 8)] :
        [NSString stringWithFormat:@"%@/%@", [bean.fourValuesDate substringWithRange:NSMakeRange(4, 2)], [bean.fourValuesDate substringFromIndex: 6]];
        NSString *hhmm = bean.fourValuesTime;
        if(hhmm.length == 6){
            hhmm = [NSString stringWithFormat:@"%@:%@", [bean.fourValuesTime substringToIndex: 2],[bean.fourValuesTime substringWithRange:NSMakeRange(2, 2)]];
        }

//        //1分足
//        if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES1] && [[bean.fourValuesTime substringWithRange:NSMakeRange(3, 1)] isEqualToString:@"0"] ) {
//            
//            CGContextStrokeLineSegments(context, dateMark, 2);
//            [hhmm drawAtPoint:CGPointMake(startX-9, startY + mainChartHeight + chartInterval + subChartHeight + 2) withAttributes: FONT_ATTRIBUTE(7)];
//        }
//        //10分足
//        if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES10] ) {
//            if([[bean.fourValuesTime substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"00"] && ![[bean.fourValuesTime substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"15"]){
//            
//                CGContextStrokeLineSegments(context, dateMark, 2);
//                [hhmm drawAtPoint:CGPointMake(startX-9, startY + mainChartHeight + chartInterval + subChartHeight + 2) withAttributes: FONT_ATTRIBUTE(7)];
//            }
//        }
//        //60分足
//        if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_TIME] && idx % 10 == 0 ) {
//            
//            CGContextStrokeLineSegments(context, dateMark, 2);
//            [hhmm drawAtPoint:CGPointMake(startX-9, startY + mainChartHeight + chartInterval + subChartHeight + 2) withAttributes: FONT_ATTRIBUTE(7)];
//        }
//        //日足
//        if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_DAY] && [[ChartBox sharedInstance] isMonthHead:bean.fourValuesDate] ){
//            
//            CGContextStrokeLineSegments(context, dateMark, 2);
//            [yyyymm drawAtPoint:CGPointMake(startX-9, startY + mainChartHeight + chartInterval + subChartHeight + 2) withAttributes: FONT_ATTRIBUTE(7)];
//        }
//        //週足
//        if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_WEEK] && idx % 15 == 0){
//
//            CGContextStrokeLineSegments(context, dateMark, 2);
//            [mmdd drawAtPoint:CGPointMake(startX-9, startY + mainChartHeight + chartInterval + subChartHeight + 2) withAttributes: FONT_ATTRIBUTE(7)];
//        }
//        //月足
//        if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MONTH] && [@"01" isEqualToString: mm]){
//            
//            CGContextStrokeLineSegments(context, dateMark, 2);
//            [yyyymm drawAtPoint:CGPointMake(startX-9, startY + mainChartHeight + chartInterval + subChartHeight + 2) withAttributes: FONT_ATTRIBUTE(7)];
//        }
        
        startX += candleStickBodyWidth + candleStickInterval;
        idx++;
    }
    
    
    
    if([ChartBox sharedInstance].needShowMovAvg){//移動平均
        [self drawTechnical_movAvg: context];
    }

    if([ChartBox sharedInstance].needShowBollinger){//ボリンジャー
        [self drawTechnical_bollinger: context];
    }

    if([ChartBox sharedInstance].needShowIchimoku){//一目均衡表
        [self drawTechnical_itimoku: context];
    }

    if([ChartBox sharedInstance].needShowSub_rsi){//RSI
        [self drawTechnical_rsi: context];
    }
    
    if([ChartBox sharedInstance].needShowSub_macd){//MACD
        [self drawTechnical_macd: context];
    }
    
    if([ChartBox sharedInstance].needShowSub_stochas){//Sストキャス
        [self drawTechnical_stochas: context];
    }
    
    if([ChartBox sharedInstance].needShowSub_volume){//出来高
        [self drawTechnical_volume: context];
    }
    
    [chartNamesView setHidden: ![ChartBox sharedInstance].needShowMovAvg];
    [chartNamesView update:1];
    [bollingerNameView setHidden: ![ChartBox sharedInstance].needShowBollinger];
    [ichimokuNameView setHidden: ![ChartBox sharedInstance].needShowIchimoku];
    [rsiNameView setHidden: ![ChartBox sharedInstance].needShowSub_rsi];
    [macdNameView setHidden: ![ChartBox sharedInstance].needShowSub_macd];
    [stochasNameView setHidden: ![ChartBox sharedInstance].needShowSub_stochas];
    [volumeNameView setHidden: ![ChartBox sharedInstance].needShowSub_volume];
    
    
    //最高値・最安値の表示
    startX = CHART_X_OFFSET + leftBorderPosition + candleStickBodyWidth / 2;
    CGFloat minPosX = startX + ([ChartBox sharedInstance].minPriceIdx) * (candleStickBodyWidth + candleStickInterval) - 8;
    minPosX = minPosX < 0 ? 0 : minPosX;
    CGFloat minPosY = startY + RATE_IN_RANGE([ChartBox sharedInstance].minPriceDisp, [ChartBox sharedInstance].minPrice,[ChartBox sharedInstance].maxPrice) * takasa ;
    NSString *strMin = [NSString stringWithFormat:@"%.2f", [ChartBox sharedInstance].minPriceDisp];
    [strMin drawAtPoint:CGPointMake(minPosX, minPosY) withAttributes: FONT_ATTRIBUTE(8)];
    
    CGFloat maxPosX = startX + ([ChartBox sharedInstance].maxPriceIdx) * (candleStickBodyWidth + candleStickInterval) - 8;
    CGFloat maxPosY = startY + RATE_IN_RANGE([ChartBox sharedInstance].maxPriceDisp, [ChartBox sharedInstance].minPrice, [ChartBox sharedInstance].maxPrice) * takasa - 9;
    NSString *strMax = [NSString stringWithFormat:@"%.2f", [ChartBox sharedInstance].maxPriceDisp];
    [strMax drawAtPoint:CGPointMake(maxPosX, maxPosY) withAttributes:FONT_ATTRIBUTE(8)];
    
    //X軸
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBStrokeColor(context, COLOR_YAXIS, 1.0);
    const CGPoint xAxis[] = {
        CGPointMake(CHART_X_OFFSET,              startY + mainChartHeight + chartInterval + subChartHeight),
        CGPointMake(CHART_X_OFFSET + chartWidth, startY + mainChartHeight + chartInterval + subChartHeight) };
    CGContextStrokeLineSegments(context, xAxis, 2);
    
    
    [activityIndicatorView stopAnimating];
    activityIndicatorView.hidden = YES;
    
    
    [self updateTechnicalLabels];
    
}



//#pragma mark - dropDownListDelegate
//
//- (void) chooseAtSection:(NSInteger)section index:(NSInteger)index{
//
//    if(section == 0){//足種
//        
//        switch (index) {
//            case 0://日足
//                self.managerViewController.ashiSelected = @"d";
//                break;
//
//            case 1://週足
//                self.managerViewController.ashiSelected = @"w";
//                break;
//                
//            case 2://月足
//                self.managerViewController.ashiSelected = @"m";
//                break;
//                
//            default:
//                break;
//        }
//        
//        [self.managerViewController fetchDataFromYahoo];
//        
//    }
//    else if(section == 1){//メインテクニカル
//        
//        technical1Selected = index;
//        [self getLimitValues];
//
//    }
//    else if(section == 2){//サブテクニカル
//        
//        technical2Selected = index;
////        [self getLimitValues];
//
//    }
//    
//    [self setNeedsDisplay];
//    
//}

//#pragma mark - dropdownList DataSource
//
//-(NSInteger)numberOfSections
//{
//    return [chooseArray count];
//}
//-(NSInteger)numberOfRowsInSection:(NSInteger)section
//{
//    NSArray *arry = chooseArray[section];
//    return [arry count];
//}
//-(NSString *)titleInSection:(NSInteger)section index:(NSInteger) index
//{
//    return chooseArray[section][index];
//}
//-(NSInteger)defaultShowSection:(NSInteger)section
//{
//    return 0;
//}


#pragma mark - Draw Technical Indicators

//移動平均線を描画
- (void)drawTechnical_movAvg: (CGContextRef)context{
//    [chartNamesView setHidden:NO];
//    [chartNamesView update:1];
//    [ichimokuNameView setHidden:YES];
//    [bollingerNameView setHidden:YES];
    

    //短期
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(MOVAVG_SHORT_COLOR[0], MOVAVG_SHORT_COLOR[1], MOVAVG_SHORT_COLOR[2]), 1.0);
    
    BOOL isFirstPoint = YES;

    startX = CHART_X_OFFSET + leftBorderPosition + candleStickBodyWidth / 2;
    for(NSDecimalNumber *ma in [ChartBox sharedInstance].movAvgShortArray_in_chart){
        if(ma != nil && ![ma isEqual:[NSNull null]]){
            CGFloat ptY = startY + RATE_IN_RANGE(ma.floatValue, [ChartBox sharedInstance].minPrice, [ChartBox sharedInstance].maxPrice) * takasa;
            
            if(isFirstPoint){
                CGContextMoveToPoint(context, startX, ptY);
                isFirstPoint = NO;
            }
            else{
                CGContextAddLineToPoint(context, startX, ptY);
                CGContextStrokePath(context);
                CGContextMoveToPoint(context, startX, ptY);
            }
            
        }
        
        startX += candleStickBodyWidth + candleStickInterval;
    }
    
    //中期
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(MOVAVG_MEDIUM_COLOR[0],MOVAVG_MEDIUM_COLOR[1],MOVAVG_MEDIUM_COLOR[2]), 1.0);
    startX = CHART_X_OFFSET + leftBorderPosition + candleStickBodyWidth / 2;
    
    isFirstPoint = YES;
    for(NSDecimalNumber *ma in [ChartBox sharedInstance].movAvgMediumArray_in_chart){
        if(ma != nil && ![ma isEqual:[NSNull null]]){
            CGFloat ptY = startY + RATE_IN_RANGE(ma.floatValue, [ChartBox sharedInstance].minPrice, [ChartBox sharedInstance].maxPrice) * takasa;
            
            if(isFirstPoint){
                CGContextMoveToPoint(context, startX, ptY);
                isFirstPoint = NO;
            }
            else{
                CGContextAddLineToPoint(context, startX, ptY);
                CGContextStrokePath(context);
                CGContextMoveToPoint(context, startX, ptY);
            }
            
        }

        
        startX += candleStickBodyWidth + candleStickInterval;
    }
    
    
    //長期
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(MOVAVG_LONG_COLOR[0], MOVAVG_LONG_COLOR[1], MOVAVG_LONG_COLOR[2]), 1.0 );
    startX = CHART_X_OFFSET + leftBorderPosition + candleStickBodyWidth / 2;
    
    isFirstPoint = YES;
    for(NSDecimalNumber *ma in [ChartBox sharedInstance].movAvgLongArray_in_chart){
        if(ma != nil && ![ma isEqual:[NSNull null]]){
            CGFloat ptY = startY + RATE_IN_RANGE(ma.floatValue, [ChartBox sharedInstance].minPrice, [ChartBox sharedInstance].maxPrice) * takasa;
            
            if(isFirstPoint){
                CGContextMoveToPoint(context, startX, ptY);
                isFirstPoint = NO;
            }
            else{
                CGContextAddLineToPoint(context, startX, ptY);
                CGContextStrokePath(context);
                CGContextMoveToPoint(context, startX, ptY);
            }
            
        }

        
        startX += candleStickBodyWidth + candleStickInterval;
    }
    
}


//ボリンジャーを描画
- (void)drawTechnical_bollinger: (CGContextRef)context{
////    [chartNamesView update:2];
//    [chartNamesView setHidden:YES];
//    [bollingerNameView setHidden:NO];
//    [ichimokuNameView setHidden:YES];


    //移動平均
    CGContextSetLineWidth(context, 1);
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(0, 0, 0),  1.0);
    startX = CHART_X_OFFSET + leftBorderPosition + candleStickBodyWidth / 2;
    BOOL isFirstPoint = YES;

    for(NSMutableArray *mutableArray in [ChartBox sharedInstance].bollingerInfoArray_in_chart){
        if(mutableArray == nil || mutableArray.count == 0){
            
        }
        else{
            NSDecimalNumber *bollinger1 = mutableArray[0];
            if( bollinger1 == nil || [bollinger1 isEqual:[NSNull null]] ){
            }
            else{
                CGFloat ptY1 = RATE_IN_RANGE( bollinger1.floatValue, [ChartBox sharedInstance].minPrice, [ChartBox sharedInstance].maxPrice) * takasa;
                if(isFirstPoint){
                    CGContextMoveToPoint(context, startX, startY + ptY1);
                    isFirstPoint = NO;
                }
                else{
                    CGContextAddLineToPoint(context, startX, startY + ptY1);
                    CGContextStrokePath(context);
                    CGContextMoveToPoint(context, startX, startY + ptY1);
                }
            }
        }
        
        startX += candleStickBodyWidth + candleStickInterval;
    }
    
    
    //TOP1
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(0, 0, 255), 1.0);
    isFirstPoint = YES;
    startX = CHART_X_OFFSET + leftBorderPosition + candleStickBodyWidth / 2;
    
    for(NSMutableArray *mutableArray in [ChartBox sharedInstance].bollingerInfoArray_in_chart){
        if(mutableArray == nil || mutableArray.count == 0){
        }
        else{
            NSDecimalNumber *bollinger1 = mutableArray[1];
            if( bollinger1 == nil || [bollinger1 isEqual:[NSNull null]] ){
            }
            else{
                CGFloat ptY1 = RATE_IN_RANGE( bollinger1.floatValue, [ChartBox sharedInstance].minPrice, [ChartBox sharedInstance].maxPrice) * takasa;
                if(isFirstPoint){
                    CGContextMoveToPoint(context, startX, startY + ptY1);
                    isFirstPoint = NO;
                }
                else{
                    CGContextAddLineToPoint(context, startX, startY + ptY1);
                    CGContextStrokePath(context);
                    CGContextMoveToPoint(context, startX, startY + ptY1);
                }
            }
        }
        
        startX += candleStickBodyWidth + candleStickInterval;
    }

    
    //LOW1
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(255, 0, 255), 1.0);
    startX = CHART_X_OFFSET + leftBorderPosition + candleStickBodyWidth / 2;
    isFirstPoint = YES;

    for(NSMutableArray *mutableArray in [ChartBox sharedInstance].bollingerInfoArray_in_chart){
        if(mutableArray == nil || mutableArray.count == 0){
        }
        else{
            NSDecimalNumber *bollinger1 = mutableArray[2];
            if( bollinger1 == nil || [bollinger1 isEqual:[NSNull null]] ){
            }
            else{
                CGFloat ptY1 = RATE_IN_RANGE( bollinger1.floatValue, [ChartBox sharedInstance].minPrice, [ChartBox sharedInstance].maxPrice) * takasa;
                if(isFirstPoint){
                    CGContextMoveToPoint(context, startX, startY + ptY1);
                    isFirstPoint = NO;
                }
                else{
                    CGContextAddLineToPoint(context, startX, startY + ptY1);
                    CGContextStrokePath(context);
                    CGContextMoveToPoint(context, startX, startY + ptY1);
                }
            }
        }
        
        startX += candleStickBodyWidth + candleStickInterval;
    }

    
    //TOP2
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(0, 255, 0), 1.0);
    startX = CHART_X_OFFSET + leftBorderPosition + candleStickBodyWidth / 2;
    isFirstPoint = YES;
    
    for(NSMutableArray *mutableArray in [ChartBox sharedInstance].bollingerInfoArray_in_chart){
        if(mutableArray == nil || mutableArray.count == 0){
        }
        else{
            NSDecimalNumber *bollinger1 = mutableArray[3];
            if( bollinger1 == nil || [bollinger1 isEqual:[NSNull null]] ){
            }
            else{
                CGFloat ptY1 = RATE_IN_RANGE( bollinger1.floatValue, [ChartBox sharedInstance].minPrice, [ChartBox sharedInstance].maxPrice) * takasa;
                if(isFirstPoint){
                    CGContextMoveToPoint(context, startX, startY + ptY1);
                    isFirstPoint = NO;
                }
                else{
                    CGContextAddLineToPoint(context, startX, startY + ptY1);
                    CGContextStrokePath(context);
                   
                    CGContextMoveToPoint(context, startX, startY + ptY1);
                }
            }
        }
        
        startX += candleStickBodyWidth + candleStickInterval;
    }

    
    //LOW2
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(255, 0, 0), 1.0);
    startX = CHART_X_OFFSET + leftBorderPosition + candleStickBodyWidth / 2;
    isFirstPoint = YES;

    for(NSMutableArray *mutableArray in [ChartBox sharedInstance].bollingerInfoArray_in_chart){
        if(mutableArray == nil || mutableArray.count == 0){
        }
        else{
            NSDecimalNumber *bollinger1 = mutableArray[4];
            if( bollinger1 == nil || [bollinger1 isEqual:[NSNull null]] ){
            }
            else{
                CGFloat ptY1 = RATE_IN_RANGE( bollinger1.floatValue, [ChartBox sharedInstance].minPrice, [ChartBox sharedInstance].maxPrice) * takasa;
                if(isFirstPoint){
                    CGContextMoveToPoint(context, startX, startY + ptY1);
                    isFirstPoint = NO;
                }
                else{
                    CGContextAddLineToPoint(context, startX, startY + ptY1);
                    CGContextStrokePath(context);
                    CGContextMoveToPoint(context, startX, startY + ptY1);
                }
            }
        }
        
        startX += candleStickBodyWidth + candleStickInterval;
    }
    
}

//一目均衡表を描画
- (void)drawTechnical_itimoku: (CGContextRef)context{
//    [chartNamesView setHidden:YES];
//    [bollingerNameView setHidden:YES];
//    [ichimokuNameView setHidden:NO];
    
    // 転換線
    CGContextSetLineWidth(context, 1);
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(ITIMOKU_CONVERSION_COLOR[0], ITIMOKU_CONVERSION_COLOR[1], ITIMOKU_CONVERSION_COLOR[2]), 1.0);
    
    BOOL isFirstPoint = YES;
    startX = CHART_X_OFFSET + leftBorderPosition + candleStickBodyWidth / 2;
    
    NSInteger ptCnt = 0;
    for(NSMutableArray *mutableArray in [ChartBox sharedInstance].itikomokuInfoArray_in_chart){
        if(mutableArray == nil || mutableArray.count == 0){
            
        }
        else{
            NSDecimalNumber *itimoku = mutableArray[0];
            if(itimoku == nil || [itimoku isEqual: [NSNull null]] ){
            }
            else{
                CGFloat ptY1 = RATE_IN_RANGE( itimoku.floatValue, [ChartBox sharedInstance].minPrice,[ChartBox sharedInstance].maxPrice) * takasa;
                if(isFirstPoint){
                    CGContextMoveToPoint(context, startX, startY + ptY1);
                    isFirstPoint = NO;
                }
                else{
                    CGContextAddLineToPoint(context, startX, startY + ptY1);
                    CGContextStrokePath(context);
                    CGContextMoveToPoint(context, startX, startY + ptY1);
                }
            }
        }
        
        startX += candleStickBodyWidth + candleStickInterval;

        ptCnt++;
        if (ptCnt == [ChartBox sharedInstance].ohlcArray_in_chart.count ){
            break;
        }
    }


    // 基準線
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(ITIMOKU_BASE_COLOR[0], ITIMOKU_BASE_COLOR[1], ITIMOKU_BASE_COLOR[2]) , 1.0);
    startX = CHART_X_OFFSET + leftBorderPosition + candleStickBodyWidth / 2;
    isFirstPoint = YES;
    ptCnt = 0;

    for(NSMutableArray *mutableArray in [ChartBox sharedInstance].itikomokuInfoArray_in_chart){
        
        if(mutableArray == nil || mutableArray.count == 0){
            
        }
        else{
            NSDecimalNumber *itimoku = mutableArray[1];
            if(itimoku == nil || [itimoku isEqual: [NSNull null]] ){
            }
            else{
                CGFloat ptY1 = RATE_IN_RANGE( itimoku.floatValue, [ChartBox sharedInstance].minPrice,[ChartBox sharedInstance].maxPrice) * takasa;
                if(isFirstPoint){
                    CGContextMoveToPoint(context, startX, startY + ptY1);
                    isFirstPoint = NO;
                }
                else{
                    CGContextAddLineToPoint(context, startX, startY + ptY1);
                    CGContextStrokePath(context);
                    CGContextMoveToPoint(context, startX, startY + ptY1);
                }
            }
        }
        
        startX += candleStickBodyWidth + candleStickInterval;
        ptCnt++;
        if (ptCnt == [ChartBox sharedInstance].ohlcArray_in_chart.count ){
            break;
        }

    }


    // 遅行線
    int laggingCnt = 0;
    int laggingCnt2 = 0;
    int laggingCnt3 = 0;
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(ITIMOKU_LAGGING_COLOR[0], ITIMOKU_LAGGING_COLOR[1], ITIMOKU_LAGGING_COLOR[2]), 1.0);
    startX = CHART_X_OFFSET + leftBorderPosition + candleStickBodyWidth / 2;
    isFirstPoint = YES;
    ptCnt = 0;
    for(NSMutableArray *mutableArray in [ChartBox sharedInstance].itikomokuInfoArray_in_chart){
        if(mutableArray == nil || mutableArray.count != 5){
            
        }
        else{
            NSDecimalNumber *itimoku = mutableArray[2];
            if(itimoku != nil && ![itimoku isEqual: [NSNull null]] ){
                CGFloat ptY1 = RATE_IN_RANGE( itimoku.floatValue, [ChartBox sharedInstance].minPrice,[ChartBox sharedInstance].maxPrice) * takasa;
                if(isFirstPoint){
                    CGContextMoveToPoint(context, startX, startY + ptY1);
                    isFirstPoint = NO;
                }
                else{
                    CGContextAddLineToPoint(context, startX, startY + ptY1);
                    CGContextStrokePath(context);
                    CGContextMoveToPoint(context, startX, startY + ptY1);
                    
                    laggingCnt3++;
                }
             
                laggingCnt++;
            }
        }
        
        laggingCnt2 ++;
        
        startX += candleStickBodyWidth + candleStickInterval;
        ptCnt++;
        if (ptCnt == [ChartBox sharedInstance].ohlcArray_in_chart.count ){
            break;
        }

    }

    
    // 先行スパン1
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(ITIMOKU_LEADING_SPAN1_COLOR[0], ITIMOKU_LEADING_SPAN1_COLOR[1], ITIMOKU_LEADING_SPAN1_COLOR[2]), 1.0);
    startX = CHART_X_OFFSET + leftBorderPosition + candleStickBodyWidth / 2;
    isFirstPoint = YES;
    ptCnt = 0;
    for(NSMutableArray *mutableArray in [ChartBox sharedInstance].itikomokuInfoArray_in_chart){
        if(mutableArray == nil || mutableArray.count == 0){
            
        }
        else{
            NSDecimalNumber *itimoku = mutableArray[3];
            if(itimoku == nil || [itimoku isEqual: [NSNull null]] ){
            }
            else{
                CGFloat ptY1 = RATE_IN_RANGE( itimoku.floatValue, [ChartBox sharedInstance].minPrice,[ChartBox sharedInstance].maxPrice) * takasa;
                if(isFirstPoint){
                    CGContextMoveToPoint(context, startX, startY + ptY1);
                    isFirstPoint = NO;
                }
                else{
                    CGContextAddLineToPoint(context, startX, startY + ptY1);
                    CGContextStrokePath(context);
                    CGContextMoveToPoint(context, startX, startY + ptY1);
                    
                }
            }
        }
        
        startX += candleStickBodyWidth + candleStickInterval;
        ptCnt++;
        if (ptCnt == [ChartBox sharedInstance].ohlcArray_in_chart.count ){
            break;
        }

    }
    
    
    // 先行スパン2
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB( ITIMOKU_LEADING_SPAN2_COLOR[0], ITIMOKU_LEADING_SPAN2_COLOR[1], ITIMOKU_LEADING_SPAN2_COLOR[2]), 1.0);
    startX = CHART_X_OFFSET + leftBorderPosition + candleStickBodyWidth / 2;
    isFirstPoint = YES;
    ptCnt = 0;
    for(NSMutableArray *mutableArray in [ChartBox sharedInstance].itikomokuInfoArray_in_chart){
        if(mutableArray == nil || mutableArray.count == 0){
            
        }
        else{
            NSDecimalNumber *itimoku = mutableArray[4];
            if(itimoku == nil || [itimoku isEqual: [NSNull null]] ){
            }
            else{
                CGFloat ptY1 = RATE_IN_RANGE( itimoku.floatValue, [ChartBox sharedInstance].minPrice,[ChartBox sharedInstance].maxPrice) * takasa;
                if(isFirstPoint){
                    CGContextMoveToPoint(context, startX, startY + ptY1);
                    isFirstPoint = NO;
                }
                else{
                    CGContextAddLineToPoint(context, startX, startY + ptY1);
                    CGContextStrokePath(context);
                    CGContextMoveToPoint(context, startX, startY + ptY1);
                    
                }
            }
        }
        
        startX += candleStickBodyWidth + candleStickInterval;
        ptCnt++;
        if (ptCnt == [ChartBox sharedInstance].ohlcArray_in_chart.count ){
            break;
        }

    }
    

    
    // 雲
    CGContextSetLineWidth(context, candleStickBodyWidth + candleStickInterval);

    startX = CHART_X_OFFSET + leftBorderPosition + candleStickBodyWidth / 2;
    ptCnt = 0;
    for(NSMutableArray *mutableArray in [ChartBox sharedInstance].itikomokuInfoArray_in_chart){
        if(mutableArray == nil || mutableArray.count == 0){
            
        }
        else{
            NSDecimalNumber *span1 = mutableArray[3];
            NSDecimalNumber *span2 = mutableArray[4];
            if(span1 == nil || [span1 isEqual: [NSNull null]] || span2 == nil || [span2 isEqual: [NSNull null]] ){
            }
            else{
                CGFloat ptYSpan1 = startY + RATE_IN_RANGE(span1.floatValue, [ChartBox sharedInstance].minPrice,[ChartBox sharedInstance].maxPrice) * takasa;
                CGFloat ptYSpan2 = startY + RATE_IN_RANGE(span2.floatValue, [ChartBox sharedInstance].minPrice,[ChartBox sharedInstance].maxPrice) * takasa;

                ptYSpan1 < ptYSpan2 ? CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(ITIMOKU_CLOUD1_COLOR[0], ITIMOKU_CLOUD1_COLOR[1], ITIMOKU_CLOUD1_COLOR[2]), 0.5) :CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB( ITIMOKU_CLOUD2_COLOR[0], ITIMOKU_CLOUD2_COLOR[1], ITIMOKU_CLOUD2_COLOR[2]), 0.5);
                
                const CGPoint cloud[] = { CGPointMake(startX, ptYSpan1), CGPointMake(startX, ptYSpan2) };
                CGContextStrokeLineSegments(context, cloud, 2);

            }
        }
        
        startX += candleStickBodyWidth + candleStickInterval;
        ptCnt++;
        if (ptCnt == [ChartBox sharedInstance].ohlcArray_in_chart.count ){
            break;
        }

    }

    
}

//RSIを描画
- (void)drawTechnical_rsi: (CGContextRef)context {
//    [rsiNameView setHidden:NO];
//    [macdNameView setHidden:YES];
//    [stochasNameView setHidden:YES];
//    [volumeNameView setHidden:YES];
    
    if([ChartBox sharedInstance].rsiInfoArray.count == 0){
        return;
    }
    
//    int term = [[ChartBox sharedInstance].technicalValueDic[@"rsi_day_1"] intValue];
    int overSellLine = [[ChartBox sharedInstance].technicalValueDic[@"rsi_day_2"] intValue];
    int overBuyLine = [[ChartBox sharedInstance].technicalValueDic[@"rsi_day_3"] intValue];
    
    
    //////////////////////////////////////////////////////////////
    
    //Y軸目盛り（株価）
    CGFloat y1 = startY + mainChartHeight + chartInterval + RATE_IN_RANGE(overBuyLine, 0.f, 100.f) * subChartHeight; //80
    CGFloat y2 = startY + mainChartHeight + chartInterval + RATE_IN_RANGE(overSellLine, 0.f, 100.f) * subChartHeight; //20
    CGFloat y3 = startY + mainChartHeight + chartInterval + subChartHeight * 0.5; //50
    
    [@(overBuyLine).stringValue drawAtPoint:CGPointMake(CHART_X_OFFSET + chartWidth + 3, y1 - 6) withAttributes:FONT_ATTRIBUTE(10)]; //80
    [@(overSellLine).stringValue drawAtPoint:CGPointMake(CHART_X_OFFSET + chartWidth + 3, y2 - 6) withAttributes:FONT_ATTRIBUTE(10)]; //20
    [@((overSellLine + overBuyLine) / 2).stringValue drawAtPoint:CGPointMake(CHART_X_OFFSET + chartWidth + 3, y3 - 6) withAttributes:FONT_ATTRIBUTE(10)]; //50
    

    //Y軸目盛り（線）
    CGContextSetLineWidth(context, LINEWIDTH_DIVIDE);

    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(RSI_OVER_BUY_COLOR[0], RSI_OVER_BUY_COLOR[1], RSI_OVER_BUY_COLOR[2]), 1.0);
    const CGPoint kakakuLine1[] = { CGPointMake(CHART_X_OFFSET, y1), CGPointMake(CHART_X_OFFSET + chartWidth, y1) };
    CGContextStrokeLineSegments(context, kakakuLine1, 2);
    const CGPoint kakakuLine2[] = { CGPointMake(CHART_X_OFFSET, y2), CGPointMake(CHART_X_OFFSET + chartWidth, y2) };
    CGContextStrokeLineSegments(context, kakakuLine2, 2);

    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(RSI_BASE_COLOR[0], RSI_BASE_COLOR[1], RSI_BASE_COLOR[2]), 1.0);
    const CGPoint kakakuLine3[] = { CGPointMake(CHART_X_OFFSET, y3), CGPointMake(CHART_X_OFFSET + chartWidth, y3) };
    CGContextStrokeLineSegments(context, kakakuLine3, 2);
   
    //////////////////////////////////////////////////////////////
    
    
    
    CGContextSetLineWidth(context, 1);
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(RSI_COLOR[0], RSI_COLOR[1], RSI_COLOR[2]), 1.0);

    NSArray *array;
    if([ChartBox sharedInstance].rsiInfoArray.count <= CANDLE_STICK_COUNT){
        array = [ChartBox sharedInstance].rsiInfoArray;
    }
    else{
        array = [[ChartBox sharedInstance].rsiInfoArray subarrayWithRange:NSMakeRange([ChartBox sharedInstance].rsiInfoArray.count - CANDLE_STICK_COUNT, CANDLE_STICK_COUNT)];
    }

    // RSI
    startX = CHART_X_OFFSET + leftBorderPosition + candleStickBodyWidth / 2;
    BOOL isFirstPoint = YES;
    for(NSDecimalNumber *rsi in array){
        if(rsi == nil || [rsi isEqual:[NSNull null]] ){
            continue;
        }
        
        CGFloat rsiY = startY + mainChartHeight + chartInterval + RATE_IN_RANGE(rsi.floatValue, 0.f, 100.f) * subChartHeight;
        if(isFirstPoint){
            CGContextMoveToPoint(context, startX, rsiY);
            isFirstPoint = NO;
        }
        else{
            CGContextAddLineToPoint(context, startX, rsiY);
            CGContextStrokePath(context);
            CGContextMoveToPoint(context, startX, rsiY);
        }
        
        startX += candleStickBodyWidth + candleStickInterval;
    }
    
    
}


//MACDを描画
- (void)drawTechnical_macd: (CGContextRef)context{
////    [subChartNamesView update:2];
//    [rsiNameView setHidden:YES];
//    [macdNameView setHidden:NO];
//    [stochasNameView setHidden:YES];
//    [volumeNameView setHidden:YES];

    NSArray *array;
    if([ChartBox sharedInstance].macdInfoArray.count <= CANDLE_STICK_COUNT){
        array = [ChartBox sharedInstance].macdInfoArray;
    }
    else{
        array = [[ChartBox sharedInstance].macdInfoArray subarrayWithRange:NSMakeRange([ChartBox sharedInstance].macdInfoArray.count - CANDLE_STICK_COUNT, CANDLE_STICK_COUNT)];
    }
    // 最大・最小
    CGFloat maxVal = 0.f;
    CGFloat minVal = 0.f;
    for(NSMutableArray *resultDatas in array){
        if( resultDatas != nil && ![resultDatas isEqual:[NSNull null]] && resultDatas.count == 3 ){
            
            CGFloat macd = [resultDatas[0] floatValue];
            CGFloat signal = [resultDatas[1] floatValue];
            CGFloat osci = [resultDatas[2] floatValue];
            
            if(macd > maxVal)
                maxVal = macd;
            if(signal > maxVal)
                maxVal = signal;
            if(osci > maxVal)
                maxVal = osci;
            
            if(macd < minVal)
                minVal = macd;
            if(signal < minVal)
                minVal = signal;
            if(osci < minVal)
                minVal = osci;
        }
    }
    
    
    //開始座標
    //中線
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB( 0, 0, 0 ), 1.0);

    CGFloat yPt0 = startY + mainChartHeight + chartInterval + subChartHeight * RATE_IN_RANGE(0.f, minVal, maxVal);
    const CGPoint line0[] = { CGPointMake(CHART_X_OFFSET, yPt0), CGPointMake(CHART_X_OFFSET + chartWidth, yPt0 ) };
    CGContextStrokeLineSegments(context, line0, 2);
    [@"0" drawAtPoint:CGPointMake(CHART_X_OFFSET + chartWidth + 3, yPt0 - 6) withAttributes:FONT_ATTRIBUTE(10)];
    
    
    // OSCI
    CGContextSetLineWidth(context, candleStickBodyWidth);
    startX = CHART_X_OFFSET + leftBorderPosition + candleStickBodyWidth / 2;
    
    for(NSMutableArray *resultDatas in array){
        
        if (resultDatas != nil && ![resultDatas isEqual:[NSNull null]] && resultDatas.count == 3
            && resultDatas[2] != nil && ![resultDatas[2] isEqual: [NSNull null]]) {
            
            CGFloat osci = [resultDatas[2] floatValue ];
            osci < 0 ? CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(MACD_OSCI_DARK_COLOR[0], MACD_OSCI_DARK_COLOR[1], MACD_OSCI_DARK_COLOR[2]), 1.0) :CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(MACD_OSCI_LIGHT_COLOR[0], MACD_OSCI_LIGHT_COLOR[1], MACD_OSCI_LIGHT_COLOR[2]), 1.0);

            CGFloat osciY = startY + mainChartHeight + chartInterval + subChartHeight * RATE_IN_RANGE(osci, minVal, maxVal);
            const CGPoint macdStick[] = { CGPointMake(startX, osciY), CGPointMake(startX, yPt0) };
            CGContextStrokeLineSegments(context, macdStick, 2);
            
        }
        
        // 描画座標の更新
        startX += candleStickBodyWidth + candleStickInterval;
    }

    
    // MACD
    CGContextSetLineWidth(context, 1);
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(MACD_COLOR[0], MACD_COLOR[1], MACD_COLOR[2]), 1.0);
    startX = CHART_X_OFFSET + leftBorderPosition + candleStickBodyWidth / 2;

    BOOL isFirstPoint = YES;

    for(NSMutableArray *resultDatas in array){
        if (resultDatas != nil && ![resultDatas isEqual:[NSNull null]] && resultDatas.count == 3
            && resultDatas[0] != nil && ![resultDatas[0] isEqual: [NSNull null]]) {
            CGFloat macdY = RATE_IN_RANGE([resultDatas[0] floatValue], minVal, maxVal) * subChartHeight + startY + mainChartHeight + chartInterval;

            if(isFirstPoint){
                CGContextMoveToPoint(context, startX,  macdY);
                isFirstPoint = NO;
            }
            else{
                CGContextAddLineToPoint(context, startX, macdY);
                CGContextStrokePath(context);
                CGContextMoveToPoint(context, startX, macdY);
            }
        }
        
        // 描画座標の更新
        startX += candleStickBodyWidth + candleStickInterval;
    }
    
    
    // シグナル
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(MACD_SIGNAL_COLOR[0], MACD_SIGNAL_COLOR[1], MACD_SIGNAL_COLOR[2]), 1.0);
    startX = CHART_X_OFFSET + leftBorderPosition + candleStickBodyWidth / 2;
    isFirstPoint = YES;
    
    for(NSMutableArray *resultDatas in array){
        if (resultDatas != nil && ![resultDatas isEqual:[NSNull null]] && resultDatas.count == 3 &&
            resultDatas[1] != nil && ![resultDatas[1] isEqual: [NSNull null]]) {
            CGFloat signalY = RATE_IN_RANGE([resultDatas[1] floatValue], minVal, maxVal) * subChartHeight + startY + mainChartHeight + chartInterval;
            
            if(isFirstPoint){
                CGContextMoveToPoint(context, startX, signalY);
                isFirstPoint = NO;
            }
            else{
                CGContextAddLineToPoint(context, startX, signalY);
                CGContextStrokePath(context);
                CGContextMoveToPoint(context, startX, signalY);
            }
        }
        
        // 描画座標の更新
        startX += candleStickBodyWidth + candleStickInterval;
    }

}


//Sストキャスを描画
- (void)drawTechnical_stochas: (CGContextRef)context{
////    [subChartNamesView update:3];
//    [rsiNameView setHidden:YES];
//    [macdNameView setHidden:YES];
//    [stochasNameView setHidden:NO];
//    [volumeNameView setHidden:YES];


//    // 高安周期
//    int highLowCircle = [[ChartBox sharedInstance].technicalValueDic[@"stochas_day_1"] intValue];
//    // d期間
//    int dTerm = [[ChartBox sharedInstance].technicalValueDic[@"stochas_day_2"] intValue];
    // 底値ライン
    int overSellLine = [[ChartBox sharedInstance].technicalValueDic[@"stochas_day_3"] intValue];
    int overBuyLine = [[ChartBox sharedInstance].technicalValueDic[@"stochas_day_4"] intValue];
    
    
    
    //////////////////////////////////////////////////////////////
    
    //Y軸目盛り（株価）
    CGFloat y1 = startY + mainChartHeight + chartInterval + RATE_IN_RANGE(overBuyLine, 0.f, 100.f) * subChartHeight;
    CGFloat y2 = startY + mainChartHeight + chartInterval + RATE_IN_RANGE(overSellLine, 0.f, 100.f) * subChartHeight;
    [ @(overBuyLine).stringValue drawAtPoint:CGPointMake(CHART_X_OFFSET + chartWidth + 3, y1 - 6) withAttributes:FONT_ATTRIBUTE(10)];
    [ @(overSellLine).stringValue drawAtPoint:CGPointMake(CHART_X_OFFSET + chartWidth + 3, y2 - 6) withAttributes:FONT_ATTRIBUTE(10)];
    
    
    //Y軸目盛り（線）
    CGContextSetLineWidth(context, LINEWIDTH_DIVIDE);
    
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(STOCHAS_OVER_BUY_COLOR[0], STOCHAS_OVER_BUY_COLOR[1], STOCHAS_OVER_BUY_COLOR[2]), 1.0);
    const CGPoint kakakuLine1[] = { CGPointMake(CHART_X_OFFSET, y1), CGPointMake(CHART_X_OFFSET + chartWidth, y1) };
    CGContextStrokeLineSegments(context, kakakuLine1, 2);
    const CGPoint kakakuLine2[] = { CGPointMake(CHART_X_OFFSET, y2), CGPointMake(CHART_X_OFFSET + chartWidth, y2) };
    CGContextStrokeLineSegments(context, kakakuLine2, 2);
    
    //////////////////////////////////////////////////////////////
    
    NSArray *array;
    if([ChartBox sharedInstance].stochasInfoArray.count <= CANDLE_STICK_COUNT){
        array = [ChartBox sharedInstance].stochasInfoArray;
    }
    else{
        array = [[ChartBox sharedInstance].stochasInfoArray subarrayWithRange:NSMakeRange([ChartBox sharedInstance].stochasInfoArray.count - CANDLE_STICK_COUNT, CANDLE_STICK_COUNT)];
    }

    
    // スローストキャス
    CGContextSetLineWidth(context, 1);

    //Slow %D
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(STOCHAS_SLOW_PER_D_COLOR[0], STOCHAS_SLOW_PER_D_COLOR[1], STOCHAS_SLOW_PER_D_COLOR[2]), 1.0);

    startX = CHART_X_OFFSET + leftBorderPosition + candleStickBodyWidth / 2;
    BOOL isFirstPoint = YES;

    for(NSMutableArray *resultDatas in array){
        if (resultDatas.count != 0 && resultDatas[0] != nil && ![resultDatas[0] isEqual: [NSNull null]]) {
            
            CGFloat SlowPerD = [resultDatas[0] floatValue];
            CGFloat SlowPerdY = startY + mainChartHeight + chartInterval + RATE_IN_RANGE(SlowPerD, 0.f, 100.f) * subChartHeight;

            if(isFirstPoint){
                CGContextMoveToPoint(context, startX, SlowPerdY);
                isFirstPoint = NO;
            }
            else{
                CGContextAddLineToPoint(context, startX, SlowPerdY);
                CGContextStrokePath(context);
                CGContextMoveToPoint(context, startX, SlowPerdY);
            }

        }

        // 描画座標の更新
        startX += candleStickBodyWidth + candleStickInterval;
    }
    
    
    //Slow %K
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(STOCHAS_SLOW_PER_K_COLOR[0], STOCHAS_SLOW_PER_K_COLOR[1], STOCHAS_SLOW_PER_K_COLOR[2]), 1.0);
    startX = CHART_X_OFFSET + leftBorderPosition + candleStickBodyWidth / 2;
    isFirstPoint = YES;
    
    for(NSMutableArray *resultDatas in array){
        if (resultDatas.count != 0 && resultDatas[1] != nil && ![resultDatas[1] isEqual: [NSNull null]]) {
            
            CGFloat SlowPerK = [resultDatas[1] floatValue ];
            CGFloat SlowPerkY = startY + mainChartHeight + chartInterval + RATE_IN_RANGE(SlowPerK, 0.f, 100.f) * subChartHeight;
            
            if(isFirstPoint){
                CGContextMoveToPoint(context, startX, SlowPerkY);
                isFirstPoint = NO;
            }
            else{
                CGContextAddLineToPoint(context, startX, SlowPerkY);
                CGContextStrokePath(context);
                CGContextMoveToPoint(context, startX, SlowPerkY);
            }
        }
        
        // 描画座標の更新
        startX += candleStickBodyWidth + candleStickInterval;
    }

}


//出来高を描画
- (void)drawTechnical_volume: (CGContextRef)context{
////    [subChartNamesView update:4];
//    [rsiNameView setHidden:YES];
//    [macdNameView setHidden:YES];
//    [stochasNameView setHidden:YES];
//    [volumeNameView setHidden:NO];
    
    //Y軸目盛り（線）
    CGContextSetRGBStrokeColor(context, COLOR_DIVIDE_LINE, 1.0);
    CGContextSetLineWidth(context, LINEWIDTH_DIVIDE);
    
    CGFloat flooredVolume = [ChartBox getTheClosestVolume:[ChartBox sharedInstance].maxVolume];
    CGFloat rate = RATE_WITH_NUMBER(flooredVolume, [ChartBox sharedInstance].maxVolume);
    

    CGFloat yPos = startY + mainChartHeight + chartInterval + rate * subChartHeight;
    const CGPoint scaleLine[] = { CGPointMake(CHART_X_OFFSET, yPos), CGPointMake(CHART_X_OFFSET + chartWidth, yPos) };
    CGContextStrokeLineSegments(context, scaleLine, 2);
    
    
    //Y軸目盛り（出来高）
    NSString *strVolume = [NSString stringWithFormat:@"%.0f", flooredVolume / 1000];
    [strVolume drawAtPoint:CGPointMake(CHART_X_OFFSET + chartWidth + 3, yPos - 6) withAttributes:FONT_ATTRIBUTE(10)];

    if(rate < 0.2){
        CGFloat theSecondVol = flooredVolume * 0.5f;
        CGFloat yPos = startY + mainChartHeight + chartInterval + RATE_WITH_NUMBER(theSecondVol, [ChartBox sharedInstance].maxVolume) * subChartHeight;
        
        const CGPoint scaleLine[] = { CGPointMake(CHART_X_OFFSET, yPos), CGPointMake(CHART_X_OFFSET + chartWidth, yPos) };
        CGContextStrokeLineSegments(context, scaleLine, 2);
        
        NSString *strVolume = [NSString stringWithFormat:@"%.0f", theSecondVol / 1000];
        [strVolume drawAtPoint:CGPointMake(CHART_X_OFFSET + chartWidth + 3, yPos - 6) withAttributes:FONT_ATTRIBUTE(10)];
    }
    
    CGContextSetLineWidth(context, candleStickBodyWidth);
    CGContextSetRGBStrokeColor(context, COLOR_WITH_RGB(0, 0, 0), 1.0);
    
    //開始座標
    startX = CHART_X_OFFSET + leftBorderPosition + candleStickBodyWidth / 2;
    for( OhlcBean *bean in [ChartBox sharedInstance].ohlcArray_in_chart ) {
        const CGPoint volumeStick[] = {
            CGPointMake(startX, startY + mainChartHeight + chartInterval + RATE_WITH_NUMBER((CGFloat)bean.turnover, (CGFloat)[ChartBox sharedInstance].maxVolume) * subChartHeight),
            CGPointMake(startX, startY + mainChartHeight + chartInterval + subChartHeight)};
        CGContextStrokeLineSegments(context, volumeStick, 2);
        
        startX += candleStickBodyWidth + candleStickInterval;
    }
    
}


#pragma mark - Table View DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == ashiTableView){
        return [ChartBox sharedInstance].ashiNameArray.count;
    }
    else if(tableView == tech1TableView){
        return [ChartBox sharedInstance].mainTechnicalNameArray.count;
    }
    else if(tableView == tech2TableView){
        return [ChartBox sharedInstance].subTechnicalNameArray.count;
    }
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"]  ;
    }
    
    [cell setBackgroundColor:[UIColor colorWithRed:118.0/255.0 green:118.0/255.0 blue:118.0/255.0 alpha:1.0]];
    cell.textLabel.font = [UIFont systemFontOfSize:10];
    cell.textLabel.textColor = [UIColor whiteColor];

    
    if(tableView == ashiTableView){
        cell.textLabel.text = [ChartBox sharedInstance].ashiNameArray[indexPath.row];

        if([cell.textLabel.text isEqualToString: self.ashiSelectButton.titleLabel.text ])
            [cell setBackgroundColor:[UIColor colorWithRed:26.0/255.0 green:99.0/255.0 blue:166.0/255.0 alpha:1.0]];

    }
    else if(tableView == tech1TableView){
        cell.textLabel.text = [ChartBox sharedInstance].mainTechnicalNameArray[indexPath.row];
        if([cell.textLabel.text isEqualToString: tech1SelectButton.titleLabel.text ])
            [cell setBackgroundColor:[UIColor colorWithRed:26.0/255.0 green:99.0/255.0 blue:166.0/255.0 alpha:1.0]];

    }
    else if(tableView == tech2TableView){
        cell.textLabel.text = [ChartBox sharedInstance].subTechnicalNameArray[indexPath.row];
        if([cell.textLabel.text isEqualToString: tech2SelectButton.titleLabel.text ])
            [cell setBackgroundColor:[UIColor colorWithRed:26.0/255.0 green:99.0/255.0 blue:166.0/255.0 alpha:1.0]];

    }
    else{
        cell.textLabel.text = @"";
    }
    
    
    return cell;
}


#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    return btnHeight;//32.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if(tableView == ashiTableView){
        [[ChartBox sharedInstance] clearDrawChartData];
        [self setNeedsDisplay];

    }
    
    
    [UIView animateWithDuration:0.3 animations:^{
        [tableView setFrame:CGRectMake(tableView.frame.origin.x, self.frame.size.height, tableView.frame.size.width, tableView.frame.size.height)];

    } completion:^(BOOL finished) {

        activityIndicatorView.hidden = NO;
        [activityIndicatorView startAnimating];

        if(tableView == ashiTableView){
            [self.ashiSelectButton setTitle: [tableView cellForRowAtIndexPath:indexPath].textLabel.text forState:UIControlStateNormal];

//            switch (indexPath.row) {
//                case 0: //一分足
//                    [ChartBox sharedInstance].ashiTypeSelected = BAR_TYPE_MINUTES1;
//                    break;
//                case 1: //１０分足
//                    [ChartBox sharedInstance].ashiTypeSelected = BAR_TYPE_MINUTES10;
//                    break;
//                case 2: //時間足
//                    [ChartBox sharedInstance].ashiTypeSelected = BAR_TYPE_TIME;
//                    break;
//                case 3://日足
//                    [ChartBox sharedInstance].ashiTypeSelected = BAR_TYPE_DAY;
//                    break;
//                case 4://週足
//                    [ChartBox sharedInstance].ashiTypeSelected = BAR_TYPE_WEEK;
//                    break;
//                case 5://月足
//                    [ChartBox sharedInstance].ashiTypeSelected = BAR_TYPE_MONTH;
//                    break;
//                default:
//                    break;
//            }
            
            
//            [self.managerViewController fetchDataFromYahoo];
//            [self currentContentsPage];
            
            
        }
        else if(tableView == tech1TableView){
            [tech1SelectButton setTitle: [tableView cellForRowAtIndexPath:indexPath].textLabel.text forState:UIControlStateNormal];
//            technical1Selected = indexPath.row;

            [ChartBox sharedInstance].needShowMovAvg = NO;
            [ChartBox sharedInstance].needShowBollinger = NO;
            [ChartBox sharedInstance].needShowIchimoku = NO;
            if(indexPath.row == 0){
                [ChartBox sharedInstance].needShowMovAvg = YES;
            }
            else if(indexPath.row == 1){
                [ChartBox sharedInstance].needShowBollinger = YES;
            }
            else if(indexPath.row == 2){
                [ChartBox sharedInstance].needShowIchimoku = YES;
            }
            else{
                
            }
            
//            [[ChartBox sharedInstance] getLimitValues_in_chart];
//            [self setNeedsDisplay];
            
            [self updateCharts];
            
            

        }
        else if(tableView == tech2TableView){
            [tech2SelectButton setTitle: [tableView cellForRowAtIndexPath:indexPath].textLabel.text forState:UIControlStateNormal];
//            technical2Selected = indexPath.row;
            
            [ChartBox sharedInstance].needShowSub_rsi = NO;
            [ChartBox sharedInstance].needShowSub_macd = NO;
            [ChartBox sharedInstance].needShowSub_stochas = NO;
            [ChartBox sharedInstance].needShowSub_volume = NO;
            if(indexPath.row == 0){
                [ChartBox sharedInstance].needShowSub_rsi = YES;
            }
            else if(indexPath.row == 1){
                [ChartBox sharedInstance].needShowSub_macd = YES;
            }
            else if(indexPath.row == 2){
                [ChartBox sharedInstance].needShowSub_stochas = YES;
            }
            else if(indexPath.row == 3){
                [ChartBox sharedInstance].needShowSub_volume = YES;
            }
            else{
                
            }
            
            
//            [self setNeedsDisplay];
            
            [self updateCharts];
        }


    } ];
    
    
}


#pragma mark - Pan Gesture Recognizer

- (void)handlePan:(id)sender {
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)sender;
    CGPoint location = [pan locationInView: self];
    CGFloat locationX = location.x;// + candleStickBodyWidth/2;
    
    if( locationX >= CHART_X_OFFSET && locationX <= CHART_X_OFFSET + chartWidth ){
        [cursorView setCenter:CGPointMake(location.x, cursorView.center.y)];
        
        //        NSInteger indexInArray =  ((NSInteger)(location.x - startX + candleStickBodyWidth/2)) / (candleStickBodyWidth + candleStickInterval);
        //        CGFloat indexInArray = (location.x - startX + candleStickBodyWidth/2) / (candleStickBodyWidth + candleStickInterval);
        //        NSInteger indexInArray = (chartWidth - locationX + startX ) / (candleStickBodyWidth + candleStickInterval);
        NSInteger indexInArray = ( locationX - CHART_X_OFFSET + candleStickBodyWidth / 2 ) / (candleStickBodyWidth + candleStickInterval);
        //        NSInteger no = [ChartBox sharedInstance].ohlcArray_in_chart.count - indexInArray - 1;
        
        NSInteger lackCount = CANDLE_STICK_COUNT - [ChartBox sharedInstance].ohlcArray_in_chart.count;
        
        //        if(/*[ChartBox sharedInstance].ohlcArray_in_chart.count*/CANDLE_STICK_COUNT - 1 >= indexInArray){
        if( indexInArray - lackCount >= 0 && indexInArray - lackCount <= [ChartBox sharedInstance].ohlcArray_in_chart.count - 1 ){
            
            OhlcBean *bean = [ChartBox sharedInstance].ohlcArray_in_chart[ indexInArray - lackCount ];
            [fourPricesView updateFourPriceLabels:bean];
        }
        else{
            [fourPricesView clearFourPrices];
        }
        
    }
    
}


#pragma mark - Button Tapped Methods


//足種、テクニカルタイプを選択
- (void)chartTypeSelect:(UIButton *)button{
    //    BOOL closed1 = NO;
    //    BOOL closed2 = NO;
    //    BOOL closed3 = NO;
    CGFloat f1 = roundf( ashiTableView.frame.origin.y );
    CGFloat f2 = roundf( self.frame.size.height );
    if(/*ashiTableView.frame.origin.y != self.frame.size.height*/ f1 != f2){
        [UIView animateWithDuration:0.3 animations:^{
            [ashiTableView setFrame:CGRectMake(ashiTableView.frame.origin.x, self.frame.size.height, ashiTableView.frame.size.width, ashiTableView.frame.size.height)];
        }];
        //        closed1 = YES;
        return;
    }
    if(tech1TableView.frame.origin.y != self.frame.size.height){
        [UIView animateWithDuration:0.3 animations:^{
            [tech1TableView setFrame:CGRectMake(tech1TableView.frame.origin.x, self.frame.size.height, tech1TableView.frame.size.width, tech1TableView.frame.size.height)];
        }];
        //        closed2 = YES;
        return;
    }
    if(tech2TableView.frame.origin.y != self.frame.size.height){
        [UIView animateWithDuration:0.3 animations:^{
            [tech2TableView setFrame:CGRectMake(tech2TableView.frame.origin.x, self.frame.size.height, tech2TableView.frame.size.width, tech2TableView.frame.size.height)];
        }];
        //        closed3 = YES;
        return;
    }
    
    NSTimeInterval duration;
    if( /*ashiTableView.frame.origin.y == self.frame.size.height*/ f1 == f2 || tech1TableView.frame.origin.y == self.frame.size.height || tech2TableView.frame.origin.y == self.frame.size.height ){
        duration = 0.4;
    }
    else{
        duration = 0.3;
    }
    
    if(button == self.ashiSelectButton){
        
        [ashiTableView reloadData];
        [UIView animateWithDuration:duration animations:^{
            if(/*ashiTableView.frame.origin.y == self.frame.size.height*/ f1 == f2){//HIDE
                [ashiTableView setFrame:CGRectMake(ashiTableView.frame.origin.x, self.ashiSelectButton.frame.origin.y-ashiTableView.frame.size.height-1, ashiTableView.frame.size.width, ashiTableView.frame.size.height)];
                
            }
            else {
                [ashiTableView setFrame:CGRectMake(ashiTableView.frame.origin.x, self.frame.size.height, ashiTableView.frame.size.width, ashiTableView.frame.size.height)];
            }
            
        }];
        
    }
    else if(button == tech1SelectButton){
        
        [tech1TableView reloadData];
        [UIView animateWithDuration:duration animations:^{
            if(tech1TableView.frame.origin.y == self.frame.size.height){
                [tech1TableView setFrame:CGRectMake(tech1TableView.frame.origin.x, tech1SelectButton.frame.origin.y-tech1TableView.frame.size.height-1, tech1TableView.frame.size.width, tech1TableView.frame.size.height)];
            }
            else{
                [tech1TableView setFrame:CGRectMake(tech1TableView.frame.origin.x, self.frame.size.height, tech1TableView.frame.size.width, tech1TableView.frame.size.height)];
            }
            
        }];
        
    }
    else if(button == tech2SelectButton){
        
        [tech2TableView reloadData];
        [UIView animateWithDuration:duration animations:^{
            if(tech2TableView.frame.origin.y == self.frame.size.height){
                [tech2TableView setFrame:CGRectMake(tech2TableView.frame.origin.x, tech2SelectButton.frame.origin.y-tech2TableView.frame.size.height-1, tech2TableView.frame.size.width, tech2TableView.frame.size.height)];
            }
            else{
                [tech2TableView setFrame:CGRectMake(tech2TableView.frame.origin.x, self.frame.size.height, tech2TableView.frame.size.width, tech2TableView.frame.size.height)];
            }
            
        }];
        
    }
    
}


//画面回転
- (void)changeOrientationButtonTapped{
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES]; //must close auto rotate
//    [self.managerViewController updateChartVisible:YES];
//    [self.managerViewController switchChart:YES];
    
    
    //     [[UIDevice currentDevice] setOrientation:UIInterfaceOrientationLandscapeRight];
    //    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    //    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
}

#pragma mark - ビューの初期化

//X軸カーソルビュー
- (void)initCursorView{
    //button color : 39, 94, 152 // button : 46 * 55
//    float cursorBtnWidth = 30.0;
//    NSLog(@">>>>>>>>>>>>>>>>>%.0f, %.0f" ,  self.frame.size.width, self.frame.size.height);
    NSInteger cursorBtnWidth = (NSInteger) self.frame.size.width / 13.0;
    NSInteger cursorBtnHeight = (NSInteger) self.frame.size.height / 15.0;
    [ChartBox sharedInstance].xCursorBtnWidth = cursorBtnWidth;
    [ChartBox sharedInstance].xCursorBtnHeight = cursorBtnHeight;
    
    cursorView = [[UIView alloc]initWithFrame:CGRectMake(chartWidth+startX-cursorBtnWidth/2, startY, cursorBtnWidth, mainChartHeight + chartInterval + subChartHeight+45)];
    cursorView.backgroundColor = [UIColor clearColor];
    [self addSubview:cursorView];
    
    UIButton *cursorButton = [[UIButton alloc]initWithFrame:CGRectMake(0, cursorView.frame.size.height-35, cursorBtnWidth, cursorBtnHeight)];
    [cursorButton setBackgroundImage:[UIImage imageNamed:@"parts_chart_cursor_x@2x.png"] forState:UIControlStateNormal];
    [cursorView addSubview:cursorButton];
    
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake( (cursorBtnWidth-1.6)/2 /*14.2*/, 0, 1.6, cursorView.frame.size.height-32)];
    lineLabel.backgroundColor = [UIColor colorWithRed:39/255.0 green:94/255.0 blue:152/255.0 alpha:0.9];
    [cursorView addSubview: lineLabel];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [cursorButton addGestureRecognizer:pan];

}

//-(void)menuShow:(UIView *)view{
//    chooseArray = [NSMutableArray arrayWithArray:@[
//                                                   @[@"日足", @"週足", @"月足"],
//                                                   @[@"移動平均", @"ボリンジャー", @"一目均衡表"],
//                                                   @[@"RSI", @"MACD", @"Sストキャス", @"出来高"], ]];
//    
//    DropDownListView * dropDownView = [[DropDownListView alloc] initWithFrame:
//                                       CGRectMake(MENU_LEFT_SPACE, 0, self.frame.size.width - MENU_LEFT_SPACE - 2*SPACE_BUTTON, view.frame.size.height) dataSource:self delegate: self backColor: @"blue" size:CGRectMake(0, 0, 0, 0)];
//    dropDownView.buttonView = view;
//    dropDownView.editJuge = YES;
//    dropDownView.mSuperView = self;
//
//    [view addSubview:dropDownView];
//}


//足種、メインテクニカル、サブテクニカルボタンの初期化
- (void)initChartSelect{

//    CGRect rect1 = CGRectMake(self.frame.size.width * 0.26, self.frame.size.height - btnHeight, self.frame.size.width*0.18, btnHeight);
//    CGRect rect2 = CGRectMake(rect1.origin.x + rect1.size.width + 5, rect1.origin.y, self.frame.size.width*0.24, rect1.size.height);
//    CGRect rect3 = CGRectMake(rect2.origin.x + rect2.size.width + 5, rect2.origin.y, self.frame.size.width*/*0.25*/0.24, rect2.size.height);
    CGFloat menuY = self.frame.size.height - btnHeight; //0.25->0.24
    CGFloat btnWidth = self.frame.size.width*0.24;
    CGRect rect3 = CGRectMake(self.frame.size.width - btnWidth - 3,  menuY, btnWidth, btnHeight);
    CGRect rect2 = CGRectMake(rect3.origin.x - rect3.size.width - 3, menuY, btnWidth, btnHeight);
    CGRect rect1 = CGRectMake(rect2.origin.x - self.frame.size.width*0.2 - 3, menuY, self.frame.size.width*0.2, btnHeight);

    
    CGFloat tbl1Height = btnHeight * [ChartBox sharedInstance].ashiNameArray.count;
    
    ashiTableView = [[UITableView alloc] initWithFrame:CGRectMake(rect1.origin.x, self.frame.size.height, rect1.size.width, tbl1Height)];
    ashiTableView.dataSource = self;
    ashiTableView.delegate = self;
    ashiTableView.backgroundColor = [UIColor clearColor];
    [self addSubview:ashiTableView];
    
    
//    UIView *ashiSelectView = [[UIView alloc]initWithFrame:CGRectMake(rect1.origin.x, rect1.origin.y - tbl1Height, rect1.size.width, tbl1Height)];
//    ashiSelectView.backgroundColor = [UIColor whiteColor];
//    for(int i = 0; i < ashiArray.count; i++){
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [btn setBackgroundImage:[UIImage imageNamed:@"button_combobox_roundedcorners_blue.png"] forState:UIControlStateNormal];
//        btn.frame = CGRectMake(0, i*btnHeight, ashiSelectView.frame.size.width, btnHeight);
//        [btn setTitle: ashiArray[i] forState:UIControlStateNormal];
//        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        btn.titleLabel.font = [UIFont systemFontOfSize:10];
//        [ashiSelectView addSubview:btn];
//        
//    }
//    [self addSubview:ashiSelectView];

    
    self.ashiSelectButton = [[UIButton alloc] initWithFrame: rect1];
    [self.ashiSelectButton setBackgroundImage:[UIImage imageNamed:@"button_combobox_roundedcorners_blue.png"] forState:UIControlStateNormal];
    [self.ashiSelectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.ashiSelectButton addTarget:self action:@selector(chartTypeSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.ashiSelectButton setTitle: [ChartBox sharedInstance].ashiNameArray[3] forState:UIControlStateNormal];
    self.ashiSelectButton.titleLabel.numberOfLines = 0;
    self.ashiSelectButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.ashiSelectButton.titleLabel.lineBreakMode = 0;
    self.ashiSelectButton.titleLabel.font = [UIFont systemFontOfSize:10];
    [self addSubview:self.ashiSelectButton];
    
    

    CGFloat tbl2Height = btnHeight * [ChartBox sharedInstance].mainTechnicalNameArray.count;
    tech1TableView = [[UITableView alloc]initWithFrame:CGRectMake(rect2.origin.x, self.frame.size.height, rect2.size.width, tbl2Height)];
    tech1TableView.dataSource = self;
    tech1TableView.delegate = self;
    [self addSubview:tech1TableView];

    
    tech1SelectButton = [[UIButton alloc] initWithFrame:rect2];
    [tech1SelectButton setBackgroundImage:[UIImage imageNamed:@"button_combobox_roundedcorners_blue.png"] forState:UIControlStateNormal];
    [tech1SelectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [tech1SelectButton addTarget:self action:@selector(chartTypeSelect:) forControlEvents:UIControlEventTouchUpInside];
    [tech1SelectButton setTitle: [ChartBox sharedInstance].mainTechnicalNameArray[0] forState:UIControlStateNormal];
    tech1SelectButton.titleLabel.numberOfLines = 0;
    tech1SelectButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    tech1SelectButton.titleLabel.lineBreakMode = 0;
    tech1SelectButton.titleLabel.font = [UIFont systemFontOfSize:10];
    [self addSubview:tech1SelectButton];

    
    
    CGFloat tbl3Height = btnHeight * [ChartBox sharedInstance].subTechnicalNameArray.count;
    tech2TableView = [[UITableView alloc]initWithFrame:CGRectMake(rect3.origin.x, self.frame.size.height, rect3.size.width, tbl3Height)];
    tech2TableView.dataSource = self;
    tech2TableView.delegate = self;
    [self addSubview:tech2TableView];

    
    tech2SelectButton = [[UIButton alloc] initWithFrame:rect3];
    [tech2SelectButton setBackgroundImage:[UIImage imageNamed:@"button_combobox_roundedcorners_blue.png"] forState:UIControlStateNormal];
    [tech2SelectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [tech2SelectButton addTarget:self action:@selector(chartTypeSelect:) forControlEvents:UIControlEventTouchUpInside];
    [tech2SelectButton setTitle: [ChartBox sharedInstance].subTechnicalNameArray[0] forState:UIControlStateNormal];
//    tech2SelectButton.titleLabel.numberOfLines = 0;
    tech2SelectButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//    tech2SelectButton.titleLabel.lineBreakMode = 0;
    tech2SelectButton.titleLabel.font = [UIFont systemFontOfSize:10];
    [self addSubview:tech2SelectButton];

}


- (void)initIchimokuNameView{
    ichimokuNameView = [[UIView alloc] initWithFrame:CGRectMake(startX, tech1LabelStringPositionY, chartWidth, 20) ];
    
    CGFloat labelWidth = 200.f;
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 3, labelWidth, 20)];
    label1.font = [UIFont systemFontOfSize:10.0];
    label1.tag = 1;
    [ichimokuNameView addSubview: label1];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake( 0, 0, labelWidth, 20)];
    label2.font = label1.font;
    label2.tag = 2;
    [ichimokuNameView addSubview: label2];
    
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake( 0, 0, labelWidth, 20)];
    label3.font = label1.font;
    label3.tag = 3;
    [ichimokuNameView addSubview: label3];
    
    UILabel *label4 = [[UILabel alloc]initWithFrame:CGRectMake( 0, 0, labelWidth, 20)];
    label4.font = label1.font;
    label4.tag = 4;
    [ichimokuNameView addSubview: label4];
    
    UILabel *label5 = [[UILabel alloc]initWithFrame:CGRectMake( 0, 0, labelWidth, 20)];
    label5.font = label1.font;
    label5.tag = 5;
    [ichimokuNameView addSubview: label5];
    
    UILabel *label6 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, labelWidth, 20)];
    label6.font = label1.font;
    label6.tag = 6;
    [ichimokuNameView addSubview: label6];
    
    
  
    int itimoku_shortTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_day_convert"] intValue];
    int itimoku_mediumTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_day_base"] intValue];
    int itimoku_longTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_day_span"] intValue];
    
    label1.text = @"一目均衡表";
    label2.text = [NSString stringWithFormat:@"転換線(%d)", itimoku_shortTerm];
    label3.text = [NSString stringWithFormat: @"基準線(%d)", itimoku_mediumTerm];
    label4.text = [NSString stringWithFormat: @"先行スパン2(%d)", itimoku_longTerm];
    label5.text = @"";
    label6.text = @"";
    
    label2.textColor = [UIColor colorWithRed:ITIMOKU_CONVERSION_COLOR[0]/255.0 green:ITIMOKU_CONVERSION_COLOR[1]/255.0 blue:ITIMOKU_CONVERSION_COLOR[2]/255.0 alpha:1.0];
    label3.textColor = [UIColor colorWithRed:ITIMOKU_BASE_COLOR[0]/255.0 green:ITIMOKU_BASE_COLOR[1]/255.0 blue:ITIMOKU_BASE_COLOR[2]/255.0 alpha:1.0];
    label4.textColor = [UIColor colorWithRed:ITIMOKU_LEADING_SPAN2_COLOR[0]/255.0 green:ITIMOKU_LEADING_SPAN2_COLOR[1]/255.0 blue:ITIMOKU_LEADING_SPAN2_COLOR[2]/255.0 alpha:1.0];
    
    [label1 sizeToFit];
    label2.frame = CGRectMake(label1.frame.origin.x + label1.frame.size.width*1.2, label1.frame.origin.y, labelWidth, 20);
    [label2 sizeToFit];
    label3.frame = CGRectMake(label2.frame.origin.x + label2.frame.size.width*1.2, label1.frame.origin.y, labelWidth, 20);
    [label3 sizeToFit];
    label4.frame = CGRectMake(label3.frame.origin.x + label3.frame.size.width*1.2, label1.frame.origin.y, labelWidth, 20);
    [label4 sizeToFit];
    label5.frame = CGRectMake(label4.frame.origin.x + label4.frame.size.width*1.2, label1.frame.origin.y, labelWidth, 20);
    [label5 sizeToFit];
    label6.frame = CGRectMake(label5.frame.origin.x + label5.frame.size.width*1.2, label1.frame.origin.y, labelWidth, 20);
    [label6 sizeToFit];
    
    
    ichimokuNameView.hidden = YES;
    [self addSubview:ichimokuNameView];
}



- (void)initBollingerNameView{
    bollingerNameView = [[UIView alloc] initWithFrame:CGRectMake(startX, tech1LabelStringPositionY, chartWidth, 20) ];
    
    CGFloat labelWidth = 200.f;
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 3, labelWidth, 20)];
    label1.font = [UIFont systemFontOfSize:10.0];
    label1.tag = 1;
    [bollingerNameView addSubview: label1];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake( 0, 0, labelWidth, 20)];
    label2.font = label1.font;
    label2.tag = 2;
    [bollingerNameView addSubview: label2];
    
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake( 0, 0, labelWidth, 20)];
    label3.font = label1.font;
    label3.tag = 3;
    [bollingerNameView addSubview: label3];
    
    UILabel *label4 = [[UILabel alloc]initWithFrame:CGRectMake( 0, 0, labelWidth, 20)];
    label4.font = label1.font;
    label4.tag = 4;
    [bollingerNameView addSubview: label4];
    
    UILabel *label5 = [[UILabel alloc]initWithFrame:CGRectMake( 0, 0, labelWidth, 20)];
    label5.font = label1.font;
    label5.tag = 5;
    [bollingerNameView addSubview: label5];
    
    UILabel *label6 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, labelWidth, 20)];
    label6.font = label1.font;
    label6.tag = 6;
    [bollingerNameView addSubview: label6];
    
    
    label1.text = @"ボリンジャー";
    label2.text = [NSString stringWithFormat:@"移動平均(%d)", [[ChartBox sharedInstance].technicalValueDic[@"bollinger_day_ma"] intValue]];
    label3.text = @"+1δ ";
    label4.text = @"-1δ ";
    label5.text = @"+2δ ";
    label6.text = @"-2δ ";
    
    label2.textColor = [UIColor colorWithRed:BOLLINGER_MOVE_AVG_COLOR[0]/255.0 green:BOLLINGER_MOVE_AVG_COLOR[1]/255.0 blue:BOLLINGER_MOVE_AVG_COLOR[2]/255.0 alpha:1.0];
    label3.textColor = [UIColor colorWithRed:BOLLINGER_TOP1_COLOR[0]/255.0 green:BOLLINGER_TOP1_COLOR[1]/255.0 blue:BOLLINGER_TOP1_COLOR[2]/255.0 alpha:1.0];
    label4.textColor = [UIColor colorWithRed:BOLLINGER_TOP2_COLOR[0]/255.0 green:BOLLINGER_TOP2_COLOR[1]/255.0 blue:BOLLINGER_TOP2_COLOR[2]/255.0 alpha:1.0];
    label5.textColor = [UIColor colorWithRed:BOLLINGER_LOW1_COLOR[0]/255.0 green:BOLLINGER_LOW1_COLOR[1]/255.0 blue:BOLLINGER_LOW1_COLOR[2]/255.0 alpha:1.0];
    label6.textColor = [UIColor colorWithRed:BOLLINGER_LOW2_COLOR[0]/255.0 green:BOLLINGER_LOW2_COLOR[1]/255.0 blue:BOLLINGER_LOW2_COLOR[2]/255.0 alpha:1.0];
    
    [label1 sizeToFit];
    label2.frame = CGRectMake(label1.frame.origin.x + label1.frame.size.width*1.2, label1.frame.origin.y, labelWidth, 20);
    [label2 sizeToFit];
    label3.frame = CGRectMake(label2.frame.origin.x + label2.frame.size.width*1.2, label1.frame.origin.y, labelWidth, 20);
    [label3 sizeToFit];
    label4.frame = CGRectMake(label3.frame.origin.x + label3.frame.size.width*1.2, label1.frame.origin.y, labelWidth, 20);
    [label4 sizeToFit];
    label5.frame = CGRectMake(label4.frame.origin.x + label4.frame.size.width*1.2, label1.frame.origin.y, labelWidth, 20);
    [label5 sizeToFit];
    label6.frame = CGRectMake(label5.frame.origin.x + label5.frame.size.width*1.2, label1.frame.origin.y, labelWidth, 20);
    [label6 sizeToFit];
    bollingerNameView.hidden = YES;
    [self addSubview:bollingerNameView];
}


- (void)initRsiNameView{
    rsiNameView = [[UIView alloc] initWithFrame:CGRectMake(startX, tech2LabelStringPositionY, chartWidth, 20) ];

    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 20)];
    label1.tag = 1;
    label1.font = [UIFont systemFontOfSize:10.0];
    [rsiNameView addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 20)];
    label2.tag = 2;
    label2.font = label1.font;
    [rsiNameView addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 20)];
    label3.tag = 3;
    label3.font = label1.font;
    [rsiNameView addSubview:label3];
    
    UILabel *label4 = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 20)];
    label4.tag = 4;
    label4.font = label1.font;
    [rsiNameView addSubview:label4];
    
    int term = [[ChartBox sharedInstance].technicalValueDic[@"rsi_day_1"] intValue];
//    int overSellLine = [[ChartBox sharedInstance].technicalValueDic[@"rsi_day_2"] intValue];
//    int overBuyLine = [[ChartBox sharedInstance].technicalValueDic[@"rsi_day_3"] intValue];
    label1.text = [NSString stringWithFormat:@"RSI(%d)", term];
    label2.text = @"売られすぎ";
    label3.text = @"基準線";
    label4.text = @"買われすぎ";
    label1.textColor = [UIColor colorWithRed: RSI_COLOR[0]/255.0 green:RSI_COLOR[1]/255.0 blue:RSI_COLOR[2]/255.0 alpha:1.0];
    label2.textColor = [UIColor colorWithRed: RSI_OVER_BUY_COLOR[0]/255.0 green:RSI_OVER_BUY_COLOR[1]/255.0 blue:RSI_OVER_BUY_COLOR[2]/255.0 alpha:1.0];
    label3.textColor = [UIColor colorWithRed: RSI_BASE_COLOR[0]/255.0 green:RSI_BASE_COLOR[1]/255.0 blue:RSI_BASE_COLOR[2]/255.0 alpha:1.0];
    label4.textColor = [UIColor colorWithRed: RSI_OVER_BUY_COLOR[0]/255.0 green:RSI_OVER_BUY_COLOR[1]/255.0 blue:RSI_OVER_BUY_COLOR[2]/255.0 alpha:1.0];


    [label1 sizeToFit];
    label2.frame = CGRectMake(label1.frame.origin.x + label1.frame.size.width + 10, 0, 20, 20);
    [label2 sizeToFit];
    label3.frame = CGRectMake(label2.frame.origin.x + label2.frame.size.width + 10, 0, 20, 20);
    [label3 sizeToFit];
    label4.frame = CGRectMake(label3.frame.origin.x + label3.frame.size.width + 10, 0, 20, 20);
    [label4 sizeToFit];

    rsiNameView.hidden = YES;
    [self addSubview:rsiNameView];
}

- (void)initMacdNameView{
    macdNameView = [[UIView alloc] initWithFrame:CGRectMake(startX, tech2LabelStringPositionY, chartWidth, 20) ];
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 20)];
    label1.tag = 1;
    label1.font = [UIFont systemFontOfSize:10.0];
    //label1.backgroundColor = [UIColor darkGrayColor];
    [macdNameView addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 20)];
    label2.tag = 2;
    label2.font = label1.font;
    //label2.backgroundColor = [UIColor darkGrayColor];
    [macdNameView addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 20)];
    label3.tag = 3;
    label3.font = label1.font;
    //label3.backgroundColor = [UIColor darkGrayColor];
    [macdNameView addSubview:label3];
    
//    UILabel *label4 = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 20)];
//    label4.tag = 4;
//    label4.font = label1.font;
//    //
//    label4.backgroundColor = [UIColor darkGrayColor];
//    [rsiNameView addSubview:label4];
    
    
    // 短期EMA
    int shortEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_day_1"] intValue];
    // 長期EMA
    int longEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_day_2"] intValue];
    // 底値ライン
    int signal = [[ChartBox sharedInstance].technicalValueDic[@"macd_day_3"] intValue];
    
    label1.text = @"MACD";
    label2.text = [NSString stringWithFormat:@"MACD(%d,%d)", shortEMA, longEMA];
    label3.text = [NSString stringWithFormat:@"シグナル(%d)", signal];
    label1.textColor = [UIColor blackColor];
    label2.textColor = [UIColor colorWithRed: MACD_COLOR[0]/255.0 green:MACD_COLOR[1]/255.0 blue:MACD_COLOR[2]/255.0 alpha:1.0];
    label3.textColor = [UIColor colorWithRed: MACD_SIGNAL_COLOR[0]/255.0 green:MACD_SIGNAL_COLOR[1]/255.0 blue:MACD_SIGNAL_COLOR[2]/255.0 alpha:1.0];

    
    [label1 sizeToFit];
    label2.frame = CGRectMake(label1.frame.origin.x + label1.frame.size.width + 10, 0, 20, 20);
    [label2 sizeToFit];
    label3.frame = CGRectMake(label2.frame.origin.x + label2.frame.size.width + 10, 0, 20, 20);
    [label3 sizeToFit];
    
    
    macdNameView.hidden = YES;
    [self addSubview:macdNameView];

    
}
- (void)initStochasNameView{
    stochasNameView = [[UIView alloc] initWithFrame:CGRectMake(startX, tech2LabelStringPositionY, chartWidth, 20) ];

    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 20)];
    label1.tag = 1;
    label1.font = [UIFont systemFontOfSize:10.0];
    [stochasNameView addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 20)];
    label2.tag = 2;
    label2.font = label1.font;
    [stochasNameView addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 20)];
    label3.tag = 3;
    label3.font = label1.font;
    [stochasNameView addSubview:label3];
    
    UILabel *label4 = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 20)];
    label4.tag = 4;
    label4.font = label1.font;
    [stochasNameView addSubview:label4];
    
    UILabel *label5 = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 20)];
    label5.tag = 5;
    label5.font = label1.font;
    [stochasNameView addSubview:label5];
    
    label1.text = [NSString stringWithFormat: @"Sストキャス(%d,%d)", 14,3];
    label2.text = @"Slow %D";
    label3.text = @"Slow %K";
    label4.text = @"売られすぎ";
    label5.text = @"買われすぎ";
    label1.textColor = [UIColor blackColor];
    label2.textColor = [UIColor colorWithRed: STOCHAS_SLOW_PER_D_COLOR[0]/255.0 green:STOCHAS_SLOW_PER_D_COLOR[1]/255.0 blue:STOCHAS_SLOW_PER_D_COLOR[2]/255.0 alpha:1.0];
    label3.textColor = [UIColor colorWithRed: STOCHAS_SLOW_PER_K_COLOR[0]/255.0 green:STOCHAS_SLOW_PER_K_COLOR[1]/255.0 blue:STOCHAS_SLOW_PER_K_COLOR[2]/255.0 alpha:1.0];
    label4.textColor = [UIColor colorWithRed: STOCHAS_OVER_SELL_COLOR[0]/255.0 green:STOCHAS_OVER_SELL_COLOR[1]/255.0 blue:STOCHAS_OVER_SELL_COLOR[2]/255.0 alpha:1.0];
    label5.textColor = [UIColor colorWithRed: STOCHAS_OVER_BUY_COLOR[0]/255.0 green:STOCHAS_OVER_BUY_COLOR[1]/255.0 blue:STOCHAS_OVER_BUY_COLOR[2]/255.0 alpha:1.0];

    [label1 sizeToFit];
    label2.frame = CGRectMake(label1.frame.origin.x + label1.frame.size.width + 5, 0, 20, 20);
    [label2 sizeToFit];
    label3.frame = CGRectMake(label2.frame.origin.x + label2.frame.size.width + 5, 0, 20, 20);
    [label3 sizeToFit];
    label4.frame = CGRectMake(label3.frame.origin.x + label3.frame.size.width + 5, 0, 20, 20);
    [label4 sizeToFit];
    label5.frame = CGRectMake(label4.frame.origin.x + label4.frame.size.width + 5, 0, 20, 20);
    [label5 sizeToFit];

    stochasNameView.hidden = YES;
    [self addSubview:stochasNameView];
}

- (void)initVolumeNameView{
    volumeNameView = [[UIView alloc]initWithFrame:CGRectMake(startX, tech2LabelStringPositionY, chartWidth, 20)];
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 20)];
    label1.tag = 1;
    label1.text = @"出来高(×1000)";
    label1.backgroundColor = [UIColor clearColor];
    label1.font = [UIFont systemFontOfSize:10.0];
    label1.textColor = [UIColor blackColor];
    [volumeNameView addSubview:label1];
    
    volumeNameView.hidden = YES;
    [self addSubview:volumeNameView];
    
}

#pragma mark - Other Mothods

- (void)updateTechnicalLabels{
    UILabel *bollingerLabel = (UILabel *)[bollingerNameView viewWithTag:2];
    int itimoku_shortTerm;
    int itimoku_mediumTerm;
    int itimoku_longTerm;
    
    int term; //RSI
    int shortEMA; // 短期EMA(MACD)
    int longEMA; // 長期EMA(MACD)
    int signal; // 底値ライン(MACD)
    int stochas1;
    int stochas2;
    
//    if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES1]) {//1分足
//        bollingerLabel.text = [NSString stringWithFormat:@"移動平均(%d)", [[ChartBox sharedInstance].technicalValueDic[@"bollinger_1min_ma"] intValue]];
//        itimoku_shortTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_1min_convert"] intValue];
//        itimoku_mediumTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_1min_base"] intValue];
//        itimoku_longTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_1min_span"] intValue];
//        
//        term = [[ChartBox sharedInstance].technicalValueDic[@"rsi_1min_1"] intValue];
//        shortEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_1min_1"] intValue];
//        longEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_1min_2"] intValue];
//        signal = [[ChartBox sharedInstance].technicalValueDic[@"macd_1min_3"] intValue];
//        stochas1 = [[ChartBox sharedInstance].technicalValueDic[@"stochas_1min_1"] intValue];
//        stochas2 = [[ChartBox sharedInstance].technicalValueDic[@"stochas_1min_2"] intValue];
//        
//        ((UILabel *)[volumeNameView viewWithTag:1]).text = @"出来高";
//    }
//    else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES10] ) {//10分足
//        bollingerLabel.text = [NSString stringWithFormat:@"移動平均(%d)", [[ChartBox sharedInstance].technicalValueDic[@"bollinger_10min_ma"] intValue]];
//        itimoku_shortTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_10min_convert"] intValue];
//        itimoku_mediumTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_10min_base"] intValue];
//        itimoku_longTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_10min_span"] intValue];
//        term = [[ChartBox sharedInstance].technicalValueDic[@"rsi_10min_1"] intValue];
//        shortEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_10min_1"] intValue];
//        longEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_10min_2"] intValue];
//        signal = [[ChartBox sharedInstance].technicalValueDic[@"macd_10min_3"] intValue];
//        stochas1 = [[ChartBox sharedInstance].technicalValueDic[@"stochas_10min_1"] intValue];
//        stochas2 = [[ChartBox sharedInstance].technicalValueDic[@"stochas_10min_2"] intValue];
//        ((UILabel *)[volumeNameView viewWithTag:1]).text = @"出来高";
//
//    }
//    else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_TIME]) {//60分足
//        bollingerLabel.text = [NSString stringWithFormat:@"移動平均(%d)", [[ChartBox sharedInstance].technicalValueDic[@"bollinger_hour_ma"] intValue]];
//        itimoku_shortTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_hour_convert"] intValue];
//        itimoku_mediumTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_hour_base"] intValue];
//        itimoku_longTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_hour_span"] intValue];
//        term = [[ChartBox sharedInstance].technicalValueDic[@"rsi_hour_1"] intValue];
//        shortEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_hour_1"] intValue];
//        longEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_hour_2"] intValue];
//        signal = [[ChartBox sharedInstance].technicalValueDic[@"macd_hour_3"] intValue];
//        stochas1 = [[ChartBox sharedInstance].technicalValueDic[@"stochas_hour_1"] intValue];
//        stochas2 = [[ChartBox sharedInstance].technicalValueDic[@"stochas_hour_2"] intValue];
//        ((UILabel *)[volumeNameView viewWithTag:1]).text = @"出来高";
//
//    }
//    else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_DAY]){//日足
//        bollingerLabel.text = [NSString stringWithFormat:@"移動平均(%d)", [[ChartBox sharedInstance].technicalValueDic[@"bollinger_day_ma"] intValue]];
//        itimoku_shortTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_day_convert"] intValue];
//        itimoku_mediumTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_day_base"] intValue];
//        itimoku_longTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_day_span"] intValue];
//        term = [[ChartBox sharedInstance].technicalValueDic[@"rsi_day_1"] intValue];
//        shortEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_day_1"] intValue];
//        longEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_day_2"] intValue];
//        signal = [[ChartBox sharedInstance].technicalValueDic[@"macd_day_3"] intValue];
//        stochas1 = [[ChartBox sharedInstance].technicalValueDic[@"stochas_day_1"] intValue];
//        stochas2 = [[ChartBox sharedInstance].technicalValueDic[@"stochas_day_2"] intValue];
//        ((UILabel *)[volumeNameView viewWithTag:1]).text = @"出来高(×1000)";
//
//    }
//    else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_WEEK]){//週足
//        bollingerLabel.text = [NSString stringWithFormat:@"移動平均(%d)", [[ChartBox sharedInstance].technicalValueDic[@"bollinger_week_ma"] intValue]];
//        itimoku_shortTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_week_convert"] intValue];
//        itimoku_mediumTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_week_base"] intValue];
//        itimoku_longTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_week_span"] intValue];
//        term = [[ChartBox sharedInstance].technicalValueDic[@"rsi_week_1"] intValue];
//        shortEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_week_1"] intValue];
//        longEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_week_2"] intValue];
//        signal = [[ChartBox sharedInstance].technicalValueDic[@"macd_week_3"] intValue];
//        stochas1 = [[ChartBox sharedInstance].technicalValueDic[@"stochas_week_1"] intValue];
//        stochas2 = [[ChartBox sharedInstance].technicalValueDic[@"stochas_week_2"] intValue];
//        ((UILabel *)[volumeNameView viewWithTag:1]).text = @"出来高(×1000)";
//
//    }
//    else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MONTH]){//月足
//        bollingerLabel.text = [NSString stringWithFormat:@"移動平均(%d)", [[ChartBox sharedInstance].technicalValueDic[@"bollinger_month_ma"] intValue]];
//        itimoku_shortTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_month_convert"] intValue];
//        itimoku_mediumTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_month_base"] intValue];
//        itimoku_longTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_month_span"] intValue];
//        term = [[ChartBox sharedInstance].technicalValueDic[@"rsi_month_1"] intValue];
//        shortEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_month_1"] intValue];
//        longEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_month_2"] intValue];
//        signal = [[ChartBox sharedInstance].technicalValueDic[@"macd_month_3"] intValue];
//        stochas1 = [[ChartBox sharedInstance].technicalValueDic[@"stochas_month_1"] intValue];
//        stochas2 = [[ChartBox sharedInstance].technicalValueDic[@"stochas_month_2"] intValue];
//        ((UILabel *)[volumeNameView viewWithTag:1]).text = @"出来高";
//    }
    
    //一目均衡表
    ((UILabel *)[ichimokuNameView viewWithTag:2]).text = [NSString stringWithFormat:@"転換線(%d)", itimoku_shortTerm];
    ((UILabel *)[ichimokuNameView viewWithTag:3]).text = [NSString stringWithFormat: @"基準線(%d)", itimoku_mediumTerm];
    ((UILabel *)[ichimokuNameView viewWithTag:4]).text = [NSString stringWithFormat: @"先行スパン2(%d)", itimoku_longTerm];
    
    //RSI
    ((UILabel *)[rsiNameView viewWithTag:1]).text = [NSString stringWithFormat:@"RSI(%d)", term];

    //MACD
    ((UILabel *)[macdNameView viewWithTag:2]).text = [NSString stringWithFormat:@"MACD(%d,%d)", shortEMA, longEMA];
    ((UILabel *)[macdNameView viewWithTag:3]).text = [NSString stringWithFormat:@"シグナル(%d)", signal];
    
    //Sストキャス
    ((UILabel *)[stochasNameView viewWithTag:1]).text = [NSString stringWithFormat: @"Sストキャス(%d,%d)", stochas1,stochas2];
    
}

- (void)updateCharts{

    [[ChartBox sharedInstance] getDrawChartData];
    
    //チャートを再描画
    [[ChartBox sharedInstance] getLimitValues_in_chart];
    [self setNeedsDisplay];
    
//    //詳細チャートを再描画
//    [self.managerViewController.dChartView updateChartsVisibility];
////    if([ChartBox sharedInstance].yAxisFixed){
////        [[ChartBox sharedInstance] getLimitValueInAll];
////    }
////    else{
////        [[ChartBox sharedInstance] getLimitValueInRange:self.managerViewController.dChartView.scrollView.contentOffset.x ];
////    }
//    [self.managerViewController.dChartView redrawChart : NO];
    
    [[ChartBox sharedInstance] saveChartSettingOptions];
}

- (void)updateButtonTitles{
//    //足種選択ボタン
//    if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES1]) {//1分足
//        [self.ashiSelectButton setTitle: [ChartBox sharedInstance].ashiNameArray[0] forState:UIControlStateNormal];
//    }
//    else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES10] ) {//10分足
//        [self.ashiSelectButton setTitle: [ChartBox sharedInstance].ashiNameArray[1] forState:UIControlStateNormal];
//    }
//    else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_TIME]) {//60分足
//        [self.ashiSelectButton setTitle: [ChartBox sharedInstance].ashiNameArray[2] forState:UIControlStateNormal];
//    }
//    else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_DAY]){//日足
//        [self.ashiSelectButton setTitle: [ChartBox sharedInstance].ashiNameArray[3] forState:UIControlStateNormal];
//    }
//    else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_WEEK]){//週足
//        [self.ashiSelectButton setTitle: [ChartBox sharedInstance].ashiNameArray[4] forState:UIControlStateNormal];
//    }
//    else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MONTH]){//月足
//        [self.ashiSelectButton setTitle: [ChartBox sharedInstance].ashiNameArray[5] forState:UIControlStateNormal];
//    }

    //テクニカル指標１選択ボタン
    if([ChartBox sharedInstance].needShowMovAvg){
        [tech1SelectButton setTitle: [ChartBox sharedInstance].mainTechnicalNameArray[0] forState:UIControlStateNormal];
    }
    if([ChartBox sharedInstance].needShowBollinger){
        [tech1SelectButton setTitle: [ChartBox sharedInstance].mainTechnicalNameArray[1] forState:UIControlStateNormal];
    }
    if([ChartBox sharedInstance].needShowIchimoku){
        [tech1SelectButton setTitle: [ChartBox sharedInstance].mainTechnicalNameArray[2] forState:UIControlStateNormal];
    }
    if(![ChartBox sharedInstance].needShowIchimoku && ![ChartBox sharedInstance].needShowBollinger && ![ChartBox sharedInstance].needShowMovAvg){
        [tech1SelectButton setTitle: [ChartBox sharedInstance].mainTechnicalNameArray[3] forState:UIControlStateNormal];
    }
    


    //テクニカル指標２選択ボタン
    if([ChartBox sharedInstance].needShowSub_rsi){
        [tech2SelectButton setTitle: [ChartBox sharedInstance].subTechnicalNameArray[0] forState:UIControlStateNormal];
    }
    if([ChartBox sharedInstance].needShowSub_macd){
        [tech2SelectButton setTitle: [ChartBox sharedInstance].subTechnicalNameArray[1] forState:UIControlStateNormal];
    }
    if([ChartBox sharedInstance].needShowSub_stochas){
        [tech2SelectButton setTitle: [ChartBox sharedInstance].subTechnicalNameArray[2] forState:UIControlStateNormal];
    }
    if([ChartBox sharedInstance].needShowSub_volume){
        [tech2SelectButton setTitle: [ChartBox sharedInstance].subTechnicalNameArray[3] forState:UIControlStateNormal];
    }
    if(![ChartBox sharedInstance].needShowSub_volume && ![ChartBox sharedInstance].needShowSub_stochas && ![ChartBox sharedInstance].needShowSub_macd && ![ChartBox sharedInstance].needShowSub_rsi){
        [tech2SelectButton setTitle: [ChartBox sharedInstance].subTechnicalNameArray[4] forState:UIControlStateNormal];
    }
    


}

#define SEND_DIC_INFO(item,kubun,key) @{ITEM_ID: item , BARTYPE_KUBUN: kubun, SETTING_VALUE: [ChartBox sharedInstance].technicalValueDic[key] }

- (void)saveTechnicalSettings{
//    [super currentContentsPage];
    
    NSArray *dict_array = @[
//                               SEND_DIC_INFO(MOVING_AVE_SHORT_TERM, BAR_TYPE_EVERY_1MIN,  @"ma_1min_s"),
//                               SEND_DIC_INFO(MOVING_AVE_SHORT_TERM, BAR_TYPE_EVERY_10MIN, @"ma_10min_s"),
//                               SEND_DIC_INFO(MOVING_AVE_SHORT_TERM, BAR_TYPE_HOURLY,      @"ma_hour_s"),
//                               SEND_DIC_INFO(MOVING_AVE_SHORT_TERM, BAR_TYPE_DAILY,       @"ma_day_s"),
//                               SEND_DIC_INFO(MOVING_AVE_SHORT_TERM, BAR_TYPE_WEEKLY,      @"ma_week_s"),
//                               SEND_DIC_INFO(MOVING_AVE_SHORT_TERM, BAR_TYPE_MONTHLY,     @"ma_month_s"),
//                               SEND_DIC_INFO(MOVING_AVE_MEDIUM_TERM, BAR_TYPE_EVERY_1MIN,  @"ma_1min_m"),
//                               SEND_DIC_INFO(MOVING_AVE_MEDIUM_TERM, BAR_TYPE_EVERY_10MIN, @"ma_10min_m"),
//                               SEND_DIC_INFO(MOVING_AVE_MEDIUM_TERM, BAR_TYPE_HOURLY,      @"ma_hour_m"),
//                               SEND_DIC_INFO(MOVING_AVE_MEDIUM_TERM, BAR_TYPE_DAILY,       @"ma_day_m"),
//                               SEND_DIC_INFO(MOVING_AVE_MEDIUM_TERM, BAR_TYPE_WEEKLY,      @"ma_week_m"),
//                               SEND_DIC_INFO(MOVING_AVE_MEDIUM_TERM, BAR_TYPE_MONTHLY,     @"ma_month_m"),
//                               SEND_DIC_INFO(MOVING_AVE_LONG_TERM, BAR_TYPE_EVERY_1MIN,  @"ma_1min_l"),
//                               SEND_DIC_INFO(MOVING_AVE_LONG_TERM, BAR_TYPE_EVERY_10MIN, @"ma_10min_l"),
//                               SEND_DIC_INFO(MOVING_AVE_LONG_TERM, BAR_TYPE_HOURLY,      @"ma_hour_l"),
//                               SEND_DIC_INFO(MOVING_AVE_LONG_TERM, BAR_TYPE_DAILY,       @"ma_day_l"),
//                               SEND_DIC_INFO(MOVING_AVE_LONG_TERM, BAR_TYPE_WEEKLY,      @"ma_week_l"),
//                               SEND_DIC_INFO(MOVING_AVE_LONG_TERM, BAR_TYPE_MONTHLY,     @"ma_month_l"),
//
//                               SEND_DIC_INFO(ICHIMOKU_SHORT_TERM, BAR_TYPE_EVERY_1MIN,  @"itimoku_1min_convert"),
//                               SEND_DIC_INFO(ICHIMOKU_SHORT_TERM, BAR_TYPE_EVERY_10MIN, @"itimoku_10min_convert"),
//                               SEND_DIC_INFO(ICHIMOKU_SHORT_TERM, BAR_TYPE_HOURLY,      @"itimoku_hour_convert"),
//                               SEND_DIC_INFO(ICHIMOKU_SHORT_TERM, BAR_TYPE_DAILY,       @"itimoku_day_convert"),
//                               SEND_DIC_INFO(ICHIMOKU_SHORT_TERM, BAR_TYPE_WEEKLY,      @"itimoku_week_convert"),
//                               SEND_DIC_INFO(ICHIMOKU_SHORT_TERM, BAR_TYPE_MONTHLY,     @"itimoku_month_convert"),
//                               SEND_DIC_INFO(ICHIMOKU_MEDIUM_TERM, BAR_TYPE_EVERY_1MIN,  @"itimoku_1min_base"),
//                               SEND_DIC_INFO(ICHIMOKU_MEDIUM_TERM, BAR_TYPE_EVERY_10MIN, @"itimoku_10min_base"),
//                               SEND_DIC_INFO(ICHIMOKU_MEDIUM_TERM, BAR_TYPE_HOURLY,      @"itimoku_hour_base"),
//                               SEND_DIC_INFO(ICHIMOKU_MEDIUM_TERM, BAR_TYPE_DAILY,       @"itimoku_day_base"),
//                               SEND_DIC_INFO(ICHIMOKU_MEDIUM_TERM, BAR_TYPE_WEEKLY,      @"itimoku_week_base"),
//                               SEND_DIC_INFO(ICHIMOKU_MEDIUM_TERM, BAR_TYPE_MONTHLY,     @"itimoku_month_base"),
//                               SEND_DIC_INFO(ICHIMOKU_LONG_TERM, BAR_TYPE_EVERY_1MIN,  @"itimoku_1min_span"),
//                               SEND_DIC_INFO(ICHIMOKU_LONG_TERM, BAR_TYPE_EVERY_10MIN, @"itimoku_10min_span"),
//                               SEND_DIC_INFO(ICHIMOKU_LONG_TERM, BAR_TYPE_HOURLY,      @"itimoku_hour_span"),
//                               SEND_DIC_INFO(ICHIMOKU_LONG_TERM, BAR_TYPE_DAILY,       @"itimoku_day_span"),
//                               SEND_DIC_INFO(ICHIMOKU_LONG_TERM, BAR_TYPE_WEEKLY,      @"itimoku_week_span"),
//                               SEND_DIC_INFO(ICHIMOKU_LONG_TERM, BAR_TYPE_MONTHLY,     @"itimoku_month_span"),
//
//                               SEND_DIC_INFO(BOLLINGER_TERM, BAR_TYPE_EVERY_1MIN,  @"bollinger_1min_ma"),
//                               SEND_DIC_INFO(BOLLINGER_TERM, BAR_TYPE_EVERY_10MIN, @"bollinger_10min_ma"),
//                               SEND_DIC_INFO(BOLLINGER_TERM, BAR_TYPE_HOURLY,      @"bollinger_hour_ma"),
//                               SEND_DIC_INFO(BOLLINGER_TERM, BAR_TYPE_DAILY,       @"bollinger_day_ma"),
//                               SEND_DIC_INFO(BOLLINGER_TERM, BAR_TYPE_WEEKLY,      @"bollinger_week_ma"),
//                               SEND_DIC_INFO(BOLLINGER_TERM, BAR_TYPE_MONTHLY,     @"bollinger_month_ma"),
//                               SEND_DIC_INFO(BOLLINGER_STANDARD_DEVIATION, BAR_TYPE_EVERY_1MIN,  @"bollinger_1min_1"),
//                               SEND_DIC_INFO(BOLLINGER_STANDARD_DEVIATION, BAR_TYPE_EVERY_10MIN, @"bollinger_10min_1"),
//                               SEND_DIC_INFO(BOLLINGER_STANDARD_DEVIATION, BAR_TYPE_HOURLY,      @"bollinger_hour_1"),
//                               SEND_DIC_INFO(BOLLINGER_STANDARD_DEVIATION, BAR_TYPE_DAILY,       @"bollinger_day_1"),
//                               SEND_DIC_INFO(BOLLINGER_STANDARD_DEVIATION, BAR_TYPE_WEEKLY,      @"bollinger_week_1"),
//                               SEND_DIC_INFO(BOLLINGER_STANDARD_DEVIATION, BAR_TYPE_MONTHLY,     @"bollinger_month_1"),
//                               SEND_DIC_INFO(BOLLINGER_STANDARD_DEVIATION2, BAR_TYPE_EVERY_1MIN,  @"bollinger_1min_2"),
//                               SEND_DIC_INFO(BOLLINGER_STANDARD_DEVIATION2, BAR_TYPE_EVERY_10MIN, @"bollinger_10min_2"),
//                               SEND_DIC_INFO(BOLLINGER_STANDARD_DEVIATION2, BAR_TYPE_HOURLY,      @"bollinger_hour_2"),
//                               SEND_DIC_INFO(BOLLINGER_STANDARD_DEVIATION2, BAR_TYPE_DAILY,       @"bollinger_day_2"),
//                               SEND_DIC_INFO(BOLLINGER_STANDARD_DEVIATION2, BAR_TYPE_WEEKLY,      @"bollinger_week_2"),
//                               SEND_DIC_INFO(BOLLINGER_STANDARD_DEVIATION2, BAR_TYPE_MONTHLY,     @"bollinger_month_2"),
//
//                               SEND_DIC_INFO(RSI_TERM, BAR_TYPE_EVERY_1MIN,  @"rsi_1min_1"),
//                               SEND_DIC_INFO(RSI_TERM, BAR_TYPE_EVERY_10MIN, @"rsi_10min_1"),
//                               SEND_DIC_INFO(RSI_TERM, BAR_TYPE_HOURLY,      @"rsi_hour_1"),
//                               SEND_DIC_INFO(RSI_TERM, BAR_TYPE_DAILY,       @"rsi_day_1"),
//                               SEND_DIC_INFO(RSI_TERM, BAR_TYPE_WEEKLY,      @"rsi_week_1"),
//                               SEND_DIC_INFO(RSI_TERM, BAR_TYPE_MONTHLY,     @"rsi_month_1"),
//                               SEND_DIC_INFO(RSI_OVERSOLD, BAR_TYPE_EVERY_1MIN,  @"rsi_1min_2"),
//                               SEND_DIC_INFO(RSI_OVERSOLD, BAR_TYPE_EVERY_10MIN, @"rsi_10min_2"),
//                               SEND_DIC_INFO(RSI_OVERSOLD, BAR_TYPE_HOURLY,      @"rsi_hour_2"),
//                               SEND_DIC_INFO(RSI_OVERSOLD, BAR_TYPE_DAILY,       @"rsi_day_2"),
//                               SEND_DIC_INFO(RSI_OVERSOLD, BAR_TYPE_WEEKLY,      @"rsi_week_2"),
//                               SEND_DIC_INFO(RSI_OVERSOLD, BAR_TYPE_MONTHLY,     @"rsi_month_2"),
//                               SEND_DIC_INFO(RSI_OVERBOUGHT, BAR_TYPE_EVERY_1MIN,  @"rsi_1min_3"),
//                               SEND_DIC_INFO(RSI_OVERBOUGHT, BAR_TYPE_EVERY_10MIN, @"rsi_10min_3"),
//                               SEND_DIC_INFO(RSI_OVERBOUGHT, BAR_TYPE_HOURLY,      @"rsi_hour_3"),
//                               SEND_DIC_INFO(RSI_OVERBOUGHT, BAR_TYPE_DAILY,       @"rsi_day_3"),
//                               SEND_DIC_INFO(RSI_OVERBOUGHT, BAR_TYPE_WEEKLY,      @"rsi_week_3"),
//                               SEND_DIC_INFO(RSI_OVERBOUGHT, BAR_TYPE_MONTHLY,     @"rsi_month_3"),
//
//                               SEND_DIC_INFO(MACD_SHORT_TERM, BAR_TYPE_EVERY_1MIN,  @"macd_1min_1"),
//                               SEND_DIC_INFO(MACD_SHORT_TERM, BAR_TYPE_EVERY_10MIN, @"macd_10min_1"),
//                               SEND_DIC_INFO(MACD_SHORT_TERM, BAR_TYPE_HOURLY,      @"macd_hour_1"),
//                               SEND_DIC_INFO(MACD_SHORT_TERM, BAR_TYPE_DAILY,       @"macd_day_1"),
//                               SEND_DIC_INFO(MACD_SHORT_TERM, BAR_TYPE_WEEKLY,      @"macd_week_1"),
//                               SEND_DIC_INFO(MACD_SHORT_TERM, BAR_TYPE_MONTHLY,     @"macd_month_1"),
//                               SEND_DIC_INFO(MACD_LONG_TERM, BAR_TYPE_EVERY_1MIN,  @"macd_1min_2"),
//                               SEND_DIC_INFO(MACD_LONG_TERM, BAR_TYPE_EVERY_10MIN, @"macd_10min_2"),
//                               SEND_DIC_INFO(MACD_LONG_TERM, BAR_TYPE_HOURLY,      @"macd_hour_2"),
//                               SEND_DIC_INFO(MACD_LONG_TERM, BAR_TYPE_DAILY,       @"macd_day_2"),
//                               SEND_DIC_INFO(MACD_LONG_TERM, BAR_TYPE_WEEKLY,      @"macd_week_2"),
//                               SEND_DIC_INFO(MACD_LONG_TERM, BAR_TYPE_MONTHLY,     @"macd_month_2"),
//                               SEND_DIC_INFO(MACD_SIGNAL, BAR_TYPE_EVERY_1MIN,  @"macd_1min_3"),
//                               SEND_DIC_INFO(MACD_SIGNAL, BAR_TYPE_EVERY_10MIN, @"macd_10min_3"),
//                               SEND_DIC_INFO(MACD_SIGNAL, BAR_TYPE_HOURLY,      @"macd_hour_3"),
//                               SEND_DIC_INFO(MACD_SIGNAL, BAR_TYPE_DAILY,       @"macd_day_3"),
//                               SEND_DIC_INFO(MACD_SIGNAL, BAR_TYPE_WEEKLY,      @"macd_week_3"),
//                               SEND_DIC_INFO(MACD_SIGNAL, BAR_TYPE_MONTHLY,     @"macd_month_3"),
//
//                               SEND_DIC_INFO(SLOW_STCSTCS_PERIOD, BAR_TYPE_EVERY_1MIN,  @"stochas_hour_1"),
//                               SEND_DIC_INFO(SLOW_STCSTCS_PERIOD, BAR_TYPE_EVERY_10MIN, @"stochas_hour_1"),
//                               SEND_DIC_INFO(SLOW_STCSTCS_PERIOD, BAR_TYPE_HOURLY,      @"stochas_hour_1"),
//                               SEND_DIC_INFO(SLOW_STCSTCS_PERIOD, BAR_TYPE_DAILY,       @"stochas_hour_1"),
//                               SEND_DIC_INFO(SLOW_STCSTCS_PERIOD, BAR_TYPE_WEEKLY,      @"stochas_hour_1"),
//                               SEND_DIC_INFO(SLOW_STCSTCS_PERIOD, BAR_TYPE_MONTHLY,     @"stochas_hour_1"),
//                               SEND_DIC_INFO(SLOW_STCSTCS_D_TERM, BAR_TYPE_EVERY_1MIN,  @"stochas_hour_2"),
//                               SEND_DIC_INFO(SLOW_STCSTCS_D_TERM, BAR_TYPE_EVERY_10MIN, @"stochas_hour_2"),
//                               SEND_DIC_INFO(SLOW_STCSTCS_D_TERM, BAR_TYPE_HOURLY,      @"stochas_hour_2"),
//                               SEND_DIC_INFO(SLOW_STCSTCS_D_TERM, BAR_TYPE_DAILY,       @"stochas_hour_2"),
//                               SEND_DIC_INFO(SLOW_STCSTCS_D_TERM, BAR_TYPE_WEEKLY,      @"stochas_hour_2"),
//                               SEND_DIC_INFO(SLOW_STCSTCS_D_TERM, BAR_TYPE_MONTHLY,     @"stochas_hour_2"),
//                               SEND_DIC_INFO(SLOW_STCSTCS_OVERSOLD, BAR_TYPE_EVERY_1MIN,  @"stochas_hour_3"),
//                               SEND_DIC_INFO(SLOW_STCSTCS_OVERSOLD, BAR_TYPE_EVERY_10MIN, @"stochas_hour_3"),
//                               SEND_DIC_INFO(SLOW_STCSTCS_OVERSOLD, BAR_TYPE_HOURLY,      @"stochas_hour_3"),
//                               SEND_DIC_INFO(SLOW_STCSTCS_OVERSOLD, BAR_TYPE_DAILY,       @"stochas_hour_3"),
//                               SEND_DIC_INFO(SLOW_STCSTCS_OVERSOLD, BAR_TYPE_WEEKLY,      @"stochas_hour_3"),
//                               SEND_DIC_INFO(SLOW_STCSTCS_OVERSOLD, BAR_TYPE_MONTHLY,     @"stochas_hour_3"),
//                               SEND_DIC_INFO(SLOW_STCSTCS_OVERBOUGHT, BAR_TYPE_EVERY_1MIN,  @"stochas_hour_4"),
//                               SEND_DIC_INFO(SLOW_STCSTCS_OVERBOUGHT, BAR_TYPE_EVERY_10MIN, @"stochas_hour_4"),
//                               SEND_DIC_INFO(SLOW_STCSTCS_OVERBOUGHT, BAR_TYPE_HOURLY,      @"stochas_hour_4"),
//                               SEND_DIC_INFO(SLOW_STCSTCS_OVERBOUGHT, BAR_TYPE_DAILY,       @"stochas_hour_4"),
//                               SEND_DIC_INFO(SLOW_STCSTCS_OVERBOUGHT, BAR_TYPE_WEEKLY,      @"stochas_hour_4"),
//                               SEND_DIC_INFO(SLOW_STCSTCS_OVERBOUGHT, BAR_TYPE_MONTHLY,     @"stochas_hour_4"),
                               ];
    

//    [self requestEvent:EDIT sendInformation:nil sendInformationList: dict_array];
    
}

//#pragma mark -
//#pragma mark 基盤からの戻り
//- (void)responseEvent:(EventResponseModel *)eventResponseModel {
//    
//    if (!eventResponseModel) {
//        return;
//    }
//    
//    if ([eventResponseModel.status isEqualToString:STATUS_NG]) {
//        return;
//    }
//    
//
//    
//    /** チャート株式・先物OP（過去） */
//    if ( [eventResponseModel.tag isEqualToString: [IdentifierTagFuturesIdxChart toString:ID_TAG_OW_FUT_IDX_CHA]] ) {
//
//        //チャートデータ関連
//        if(chartMemoryManager == nil)
//            chartMemoryManager = [[ChartMemoryManager alloc] init];
//
//        NSMutableArray *mutableArray;
//
//        if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString: BAR_TYPE_MINUTES1]){
//            mutableArray = [chartMemoryManager selectOhlcHisOth];
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString: BAR_TYPE_MINUTES10]){
//            mutableArray = [chartMemoryManager selectOhlcHisOth];
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString: BAR_TYPE_TIME]){
//            mutableArray = [chartMemoryManager selectOhlcHisOth];
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString: BAR_TYPE_DAY]){
//            mutableArray = [chartMemoryManager selectOhlcHisDay];
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString: BAR_TYPE_WEEK]){
//            mutableArray = [chartMemoryManager selectOhlcHisWeek];
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString: BAR_TYPE_MONTH]){
//            mutableArray = [chartMemoryManager selectOhlcHisMonth];
//        }
//        
//        
//        int cnt = 0;
//        for(OhlcModel *ohlcModel in mutableArray){
//            OhlcBean *bean = [[OhlcBean alloc]init];
//            bean.fourValuesDate = ohlcModel.date;//日付
//            bean.fourValuesTime = ohlcModel.time;//時刻
//            bean.openPrice = [[NSDecimalNumber alloc] initWithString: ohlcModel.openPrice]; //始値
//            bean.highPrice = [[NSDecimalNumber alloc] initWithString: ohlcModel.highPrice]; //高値
//            bean.lowPrice = [[NSDecimalNumber alloc] initWithString: ohlcModel.lowPrice]; //安値
//            bean.closePrice = [[NSDecimalNumber alloc] initWithString: ohlcModel.closePrice]; //終値
//            bean.turnover = [ohlcModel.turnover integerValue]; //出来高
//            bean.previousOpenPrice = [[NSDecimalNumber alloc] initWithString: ohlcModel.previousOpenPrice]; //前日始値
//            bean.previousHighPrice = [[NSDecimalNumber alloc] initWithString: ohlcModel.previousHighPrice]; //前日高値
//            bean.previousLowPrice = [[NSDecimalNumber alloc] initWithString: ohlcModel.previousLowPrice]; //前日安値
//            bean.previousClosePrice = [[NSDecimalNumber alloc] initWithString: ohlcModel.previousClosePrice]; //前日終値
//            
//            [[ChartBox sharedInstance].ohlcMutableArray addObject:bean];
//            cnt++;
//            if(cnt >= CANDLESTICK_COUNT_ALL){
//                break;
//            }
//        }
//
//        NSLog(@"チャート過去(株式・先物) 情報取得：%ld件", [ChartBox sharedInstance].ohlcMutableArray.count);
//        
//        
//        if([ChartBox sharedInstance].ohlcMutableArray.count == 0){
//            NSString *message = @"チャート情報を取得できません。描画終了";
//            NSLog( @"%@", message );
//            
////            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
////            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
//            
//        }
//        else{
//
//            [self updateCharts];
//        }
//        
//        
//        
//
//    }
//    
//    /** チャート株式・先物OP（リアル） */
//    if ( [eventResponseModel.tag isEqualToString: [IdentifierTagFuturesIdxChart toString:ID_TAG_OX_FUT_IDX_CHA] ] ) {
//        NSLog(@"チャートリアル(株式・先物) 情報が届いた");
//    }
//
//    /** チャート指数（過去） */
//    if ( [eventResponseModel.tag isEqualToString: [IdentifierTagFuturesIdxChart toString:ID_TAG_OY] ] ) {
//        NSLog(@"チャート過去(指数) 情報が届いた");
//    }
//
//    /** チャート指数（リアル） */
//    if ( [eventResponseModel.tag isEqualToString: [IdentifierTagFuturesIdxChart toString:ID_TAG_OZ] ] ) {
//        NSLog(@"チャートリアル(指数) 情報が届いた");
//    }
//    
//    //銘柄情報
//    if([eventResponseModel.tag isEqualToString:[IdentifierTagStock toString:ID_TAG_OG]] || [eventResponseModel.tag isEqualToString:[IdentifierTagFuturesIdx toString:ID_TAG_ON]]){
//        
//        //銘柄コード
//        NSString *cd = eventResponseModel.receiveInfoList[0][ISSUE_CODE];
//        //銘柄名
//        NSString *nm = eventResponseModel.receiveInfoList[0][ISSUE_NAME];
//        //市場名
//        NSString *exName = eventResponseModel.receiveInfoList[0][EX_NAME];
//
//        [self.managerViewController.dChartView updateBottomBarNm:nm Cd:cd ex:exName ];
//    }
//
//
//    //TICK
//    
//}
//
//- (void)currentContentsPage {
//    [super currentContentsPage];
//
//    NSDictionary *sendInformationDictionary = @{COMMODITY_KUBUN:self.commodityKubun, //商品区分
//                                                COMMODITY_CODE: self.commodityCode, //商品コード
//                                                BARTYPE_KUBUN: [ChartBox sharedInstance].ashiTypeSelected, //足区分
//                                                ISSUE_CODE: self.issueCode, //銘柄コード
//                                                EX_CODE: self.exCode}; //取引所コード
//
//    //チャート情報取得
////    [self requestEvent:START sendInformation:sendInformationDictionary sendInformationList:nil];
//    [self requestEvent:START_NEXT2 sendInformation:sendInformationDictionary sendInformationList:nil];
//    
//    //銘柄情報取得
//    NSArray *requestDataList = [[NSArray alloc]initWithObjects:sendInformationDictionary, nil];
//    [self requestEvent:START_NEXT1 sendInformation:nil sendInformationList:requestDataList];
//    
//}
//
//
//- (void)eliminated {
//    [[ChartBox sharedInstance] clearDrawChartData];
//    [self requestEvent:FINISH sendInformation:nil sendInformationList:nil];
//    
//}
//
//
//- (NSString *)screenId {
//    super.screenId = S2006_1;
//    return super.screenId;
//}

@end
