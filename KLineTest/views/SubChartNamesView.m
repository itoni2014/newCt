

#import "SubChartNamesView.h"
#import "ChartBox.h"

@interface SubChartNamesView()
{
    BOOL _isPortrait;
    CGFloat labelWidth;
}
@end

@implementation SubChartNamesView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        
    }
    return self;
    
}

- (id)initWithFrame:(CGRect)frame orientation: (BOOL)isPortrait{
    
    self = [self initWithFrame:frame];
    labelWidth = 300.f;
    _isPortrait = isPortrait;
    self.userInteractionEnabled = NO;
    
    if(isPortrait){
        self.backgroundColor = [UIColor yellowColor];// clearColor];
    }
    else{
        self.backgroundColor = [UIColor colorWithRed:101/255.0 green:122/255.0 blue:141/255.0 alpha:0.85];
    }

    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, labelWidth, 20)];
    label1.tag = 1;
    label1.font = [UIFont systemFontOfSize:10.0];
//    label1.backgroundColor = [UIColor darkGrayColor];
    [self addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, labelWidth, 20)];
    label2.tag = 2;
    label2.font = label1.font;
//    label2.backgroundColor = [UIColor darkGrayColor];
    [self addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, labelWidth, 20)];
    label3.tag = 3;
    label3.font = label1.font;
//    label3.backgroundColor = [UIColor darkGrayColor];
    [self addSubview:label3];
    
    UILabel *label4 = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, labelWidth, 20)];
    label4.tag = 4;
    label4.font = label1.font;
//    label4.backgroundColor = [UIColor darkGrayColor];
    [self addSubview:label4];
    
    UILabel *label5 = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, labelWidth, 20)];
    label5.tag = 5;
    label5.font = label1.font;
//    label5.backgroundColor = [UIColor darkGrayColor];
    [self addSubview:label5];
    
    return self;
}

- (void)update: (NSInteger)technicalType{
    
    UILabel *label1 = (UILabel *)[self viewWithTag:1];
    UILabel *label2 = (UILabel *)[self viewWithTag:2];
    UILabel *label3 = (UILabel *)[self viewWithTag:3];
    UILabel *label4 = (UILabel *)[self viewWithTag:4];
    UILabel *label5 = (UILabel *)[self viewWithTag:5];
    label1.frame = [self getOriginalSize:label1];
    label2.frame = [self getOriginalSize:label2];
    label3.frame = [self getOriginalSize:label3];
    label4.frame = [self getOriginalSize:label4];
    label5.frame = [self getOriginalSize:label5];
    
    if(technicalType == 1){
        int term;
//        int overSellLine = [[ChartBox sharedInstance].technicalValueDic[@"rsi_day_2"] intValue];
//        int overBuyLine = [[ChartBox sharedInstance].technicalValueDic[@"rsi_day_3"] intValue];

//        if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES1]) {//1分足
//            term = [[ChartBox sharedInstance].technicalValueDic[@"rsi_1min_1"] intValue];
//        }
//        else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES10] ) {//10分足
//            term = [[ChartBox sharedInstance].technicalValueDic[@"rsi_10min_1"] intValue];
//        }
//        else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_TIME]) {//60分足
//            term = [[ChartBox sharedInstance].technicalValueDic[@"rsi_hour_1"] intValue];
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_DAY]){//日足
//            term = [[ChartBox sharedInstance].technicalValueDic[@"rsi_day_1"] intValue];
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_WEEK]){//週足
//            term = [[ChartBox sharedInstance].technicalValueDic[@"rsi_week_1"] intValue];
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MONTH]){//月足
//            term = [[ChartBox sharedInstance].technicalValueDic[@"rsi_month_1"] intValue];
//        }
        
        label1.text = [NSString stringWithFormat:@"RSI(%d)", term];
        label2.text = @"売られすぎ";
        label3.text = @"基準線";
        label4.text = @"買われすぎ";
        label5.text = @"";
        label1.textColor = [UIColor colorWithRed: RSI_COLOR[0]/255.0 green:RSI_COLOR[1]/255.0 blue:RSI_COLOR[2]/255.0 alpha:1.0];
        label2.textColor = [UIColor colorWithRed: RSI_OVER_BUY_COLOR[0]/255.0 green:RSI_OVER_BUY_COLOR[1]/255.0 blue:RSI_OVER_BUY_COLOR[2]/255.0 alpha:1.0];
        label3.textColor = [UIColor colorWithRed: RSI_BASE_COLOR[0]/255.0 green:RSI_BASE_COLOR[1]/255.0 blue:RSI_BASE_COLOR[2]/255.0 alpha:1.0];
        label4.textColor = [UIColor colorWithRed: RSI_OVER_BUY_COLOR[0]/255.0 green:RSI_OVER_BUY_COLOR[1]/255.0 blue:RSI_OVER_BUY_COLOR[2]/255.0 alpha:1.0];
        
    }
    else if(technicalType == 2){
        // 短期EMA
        int shortEMA;
        // 長期EMA
        int longEMA;
        // 底値ライン
        int signal;
        
        
//        if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES1]) {//1分足
//            shortEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_1min_1"] intValue];
//            longEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_1min_2"] intValue];
//            signal = [[ChartBox sharedInstance].technicalValueDic[@"macd_1min_3"] intValue];
//
//        }
//        else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES10] ) {//10分足
//            shortEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_10min_1"] intValue];
//            longEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_10min_2"] intValue];
//            signal = [[ChartBox sharedInstance].technicalValueDic[@"macd_10min_3"] intValue];
//            
//        }
//        else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_TIME]) {//60分足
//            shortEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_hour_1"] intValue];
//            longEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_hour_2"] intValue];
//            signal = [[ChartBox sharedInstance].technicalValueDic[@"macd_hour_3"] intValue];
//            
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_DAY]){//日足
//            shortEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_day_1"] intValue];
//            longEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_day_2"] intValue];
//            signal = [[ChartBox sharedInstance].technicalValueDic[@"macd_day_3"] intValue];
//            
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_WEEK]){//週足
//            shortEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_week_1"] intValue];
//            longEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_week_2"] intValue];
//            signal = [[ChartBox sharedInstance].technicalValueDic[@"macd_week_3"] intValue];
//            
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MONTH]){//月足
//            shortEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_month_1"] intValue];
//            longEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_month_2"] intValue];
//            signal = [[ChartBox sharedInstance].technicalValueDic[@"macd_month_3"] intValue];
//            
//        }
        
        
        label1.text = @"MACD";
        label2.text = [NSString stringWithFormat:@"MACD(%d,%d)", shortEMA, longEMA];
        label3.text = [NSString stringWithFormat:@"シグナル(%d)", signal];
        label4.text = @"";
        label5.text = @"";
        label1.textColor = [UIColor blackColor];
        label2.textColor = [UIColor colorWithRed: MACD_COLOR[0]/255.0 green:MACD_COLOR[1]/255.0 blue:MACD_COLOR[2]/255.0 alpha:1.0];
        label3.textColor = [UIColor colorWithRed: MACD_SIGNAL_COLOR[0]/255.0 green:MACD_SIGNAL_COLOR[1]/255.0 blue:MACD_SIGNAL_COLOR[2]/255.0 alpha:1.0];
        
        
    }
    else if(technicalType == 3){
        int stochas1;
        int stochas2;
//        if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES1]) {//1分足
//            stochas1 = [[ChartBox sharedInstance].technicalValueDic[@"stochas_1min_1"] intValue];
//            stochas2 = [[ChartBox sharedInstance].technicalValueDic[@"stochas_1min_2"] intValue];
//
//        }
//        else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES10] ) {//10分足
//            stochas1 = [[ChartBox sharedInstance].technicalValueDic[@"stochas_10min_1"] intValue];
//            stochas2 = [[ChartBox sharedInstance].technicalValueDic[@"stochas_10min_2"] intValue];
//            
//        }
//        else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_TIME]) {//60分足
//            stochas1 = [[ChartBox sharedInstance].technicalValueDic[@"stochas_hour_1"] intValue];
//            stochas2 = [[ChartBox sharedInstance].technicalValueDic[@"stochas_hour_2"] intValue];
//            
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_DAY]){//日足
//            stochas1 = [[ChartBox sharedInstance].technicalValueDic[@"stochas_day_1"] intValue];
//            stochas2 = [[ChartBox sharedInstance].technicalValueDic[@"stochas_day_2"] intValue];
//            
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_WEEK]){//週足
//            stochas1 = [[ChartBox sharedInstance].technicalValueDic[@"stochas_week_1"] intValue];
//            stochas2 = [[ChartBox sharedInstance].technicalValueDic[@"stochas_week_2"] intValue];
//            
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MONTH]){//月足
//            stochas1 = [[ChartBox sharedInstance].technicalValueDic[@"stochas_month_1"] intValue];
//            stochas2 = [[ChartBox sharedInstance].technicalValueDic[@"stochas_month_2"] intValue];
//            
//        }
        
        label1.text = [NSString stringWithFormat: @"Sストキャス(%d,%d)", stochas1, stochas2];
        label2.text = @"Slow %D";
        label3.text = @"Slow %K";
        label4.text = @"売られすぎ";
        label5.text = @"買われすぎ";

        label1.textColor = [UIColor blackColor];
        label2.textColor = [UIColor colorWithRed: STOCHAS_SLOW_PER_D_COLOR[0]/255.0 green:STOCHAS_SLOW_PER_D_COLOR[1]/255.0 blue:STOCHAS_SLOW_PER_D_COLOR[2]/255.0 alpha:1.0];
        label3.textColor = [UIColor colorWithRed: STOCHAS_SLOW_PER_K_COLOR[0]/255.0 green:STOCHAS_SLOW_PER_K_COLOR[1]/255.0 blue:STOCHAS_SLOW_PER_K_COLOR[2]/255.0 alpha:1.0];
        label4.textColor = [UIColor colorWithRed: STOCHAS_OVER_SELL_COLOR[0]/255.0 green:STOCHAS_OVER_SELL_COLOR[1]/255.0 blue:STOCHAS_OVER_SELL_COLOR[2]/255.0 alpha:1.0];
        label5.textColor = [UIColor colorWithRed: STOCHAS_OVER_BUY_COLOR[0]/255.0 green:STOCHAS_OVER_BUY_COLOR[1]/255.0 blue:STOCHAS_OVER_BUY_COLOR[2]/255.0 alpha:1.0];
        
        
    }
    else if(technicalType == 4){
//        if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES1]) {//1分足
//            label1.text = @"出来高";
//        }
//        else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES10] ) {//10分足
//            label1.text = @"出来高";
//        }
//        else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_TIME]) {//60分足
//            label1.text = @"出来高";
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_DAY]){//日足
//            label1.text = @"出来高(×1000)";
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_WEEK]){//週足
//            label1.text = @"出来高(×1000)";
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MONTH]){//月足
//            label1.text = @"出来高";
//        }
        label2.text = @"";
        label3.text = @"";
        label4.text = @"";
        label5.text = @"";
        label1.textColor = [UIColor blackColor];
    }
    else{
        label1.text = @"";
        label2.text = @"";
        label3.text = @"";
        label4.text = @"";
        label5.text = @"";
        
    }
    
    if(_isPortrait){
        [label1 sizeToFit];

//        CGRect rect = label1.frame;
        
        label2.frame = CGRectMake(label1.frame.origin.x + label1.frame.size.width + 10, 0, 20, 20);
        [label2 sizeToFit];
        label3.frame = CGRectMake(label2.frame.origin.x + label2.frame.size.width + 10, 0, 20, 20);
        [label3 sizeToFit];
        label4.frame = CGRectMake(label3.frame.origin.x + label3.frame.size.width + 10, 0, 20, 20);
        [label4 sizeToFit];
        label5.frame = CGRectMake(label4.frame.origin.x + label4.frame.size.width + 10, 0, 20, 20);
        [label5 sizeToFit];
        
    }
    else{
        [label1 sizeToFit];
        label2.frame = CGRectMake(label1.frame.origin.x, label1.frame.origin.y + label1.frame.size.height * 1.2, 20, 20);
        [label2 sizeToFit];
        label3.frame = CGRectMake(label2.frame.origin.x, label2.frame.origin.y + label2.frame.size.height * 1.2, 20, 20);
        [label3 sizeToFit];
        label4.frame = CGRectMake(label3.frame.origin.x, label3.frame.origin.y + label3.frame.size.height * 1.2, 20, 20);
        [label4 sizeToFit];
        label5.frame = CGRectMake(label4.frame.origin.x, label4.frame.origin.y + label4.frame.size.height * 1.2, 20, 20);
        [label5 sizeToFit];
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, label5.frame.origin.y + label5.frame.size.height + 3);
    }
    
}

- (CGRect)getOriginalSize: (UILabel *)label{
    return CGRectMake(label.frame.origin.x, label.frame.origin.y, labelWidth, 20);
}

@end
